import Foundation

/// Searches a single substitution at fixed total mass, using the calculator's source-data basis.
struct RationRecommendationEngine {
    let calculator: any RationCalculating
    private let tolerance = 1e-9
    
    /// Legacy flat selection; grouped UI uses recommendGroups instead.
    func recommend(
        for snapshot: RationCalculationResult,
        catalog: [FeedIngredient],
        season: RationSeason? = nil
    ) throws -> [RationRecommendation] {
        let proposals = try candidateProposals(for: snapshot, catalog: catalog)
        return bestAlternatives(proposals, season: season)
    }
    
    /// Search every eligible pair before selecting up to three alternatives per deficient target.
    func recommendGroups(
        for snapshot: RationCalculationResult,
        catalog: [FeedIngredient],
        season: RationSeason? = nil
    ) throws -> [RationRecommendationGroup] {
        let proposals = try candidateProposals(for: snapshot, catalog: catalog)
        guard let before = proposals.first?.before else { return [] }
        let baseline = targets(before)
        return RationRecommendationTarget.allCases.compactMap { target in
            let index = target.comparisonIndex
            guard let start = baseline[index], start < 1 - tolerance else { return nil }
            let eligible = proposals.filter { proposal in
                guard let end = targets(proposal.after)[index] else { return false }
                return min(end, 1) > min(start, 1) + tolerance
            }
            let alternatives = bestAlternatives(eligible, season: season).map { proposal in
                var labeled = proposal
                labeled.target = target
                return labeled
            }
            guard !alternatives.isEmpty else { return nil }
            return RationRecommendationGroup(target: target, alternatives: alternatives)
        }
    }
    
    private func bestAlternatives(
        _ proposals: [RationRecommendation], season: RationSeason?
    ) -> [RationRecommendation] {
        var seenPairs = Set<String>()
        return Array(proposals.sorted { isBetter($0, than: $1, season: season) }
            .filter { seenPairs.insert($0.id).inserted }
            .prefix(3))
    }
    
    private func candidateProposals(
        for snapshot: RationCalculationResult, catalog: [FeedIngredient]
    ) throws -> [RationRecommendation] {
        // Recalculate saved snapshots against the current calculator and reference rules.
        let before = try calculator.calculate(profile: snapshot.profile, items: snapshot.items)
        guard before.requirements.crudeProteinPercent > 0,
              let requiredTDN = before.requirements.totalDigestibleNutrientsPercent,
              requiredTDN > 0 else {
            throw RationCalculationError.unavailableRequirements
        }
        let baseline = targets(before)
        guard baseline.contains(where: { value in
            guard let value else { return true }
            return value < 1 - tolerance
        }) else { return [] }
        
        var proposals: [RationRecommendation] = []
        var seenIDs = Set<String>()
        let candidates = (before.items.map(\.ingredient) + catalog).filter { seenIDs.insert($0.id).inserted }
        for source in before.items {
            for candidate in candidates where candidate.category == source.ingredient.category
            && candidate.id != source.id
            && candidate.name.lowercased() != source.ingredient.name.lowercased() {
                guard before.profile.sex != .male || !candidate.triggersGossypolWarning else { continue }
                guard let full = try? calculator.calculate(
                    profile: before.profile,
                    items: replacing(source: source, with: candidate, amount: source.kilogramsPerAnimalPerDay, in: before.items)
                ) else { continue }
                
                let endpoint = targets(full)
                var fractions = [1.0]
                for (start, end) in zip(baseline, endpoint) {
                    guard let start, let end, abs(end - start) > tolerance else { continue }
                    let crossing = (1 - start) / (end - start)
                    if crossing > 0 && crossing < 1 { fractions.append(crossing) }
                }
                
                for fraction in fractions {
                    let calculatedAmount =
                        source.kilogramsPerAnimalPerDay * fraction

                    guard calculatedAmount > 0 else { continue }

                    let roundedAmount =
                        (calculatedAmount * 100).rounded(.up) / 100

                    let amount = max(1.0, roundedAmount)

                    guard amount <= source.kilogramsPerAnimalPerDay else {
                        continue
                    }

                    // Hitung ulang menggunakan porsi minimal 1 kg.
                    guard let after = try? calculator.calculate(
                        profile: before.profile,
                        items: replacing(
                            source: source,
                            with: candidate,
                            amount: amount,
                            in: before.items
                        )
                    ) else { continue }

                    let outcome = targets(after)

                    guard preservesKnownTargets(baseline, outcome),
                          improves(baseline, outcome) else {
                        continue
                    }

                    let proposal = RationRecommendation(
                        removedIngredient: source.ingredient,
                        addedIngredient: candidate,
                        replacedKilograms: amount,
                        before: before,
                        after: after
                    )

                    proposals.append(proposal)
                }
            }
        }

        return proposals
        }
        
        enum SimulationError: Error {
            case invalidPortion
        }
        
        /// Uses the same calculation as recommendations; the original snapshot stays unchanged.
        func simulate(_ recommendation: RationRecommendation, amount: Double) throws -> RationCalculationResult {
            guard let source = recommendation.before.items.first(where: { $0.id == recommendation.removedIngredient.id }),
                  amount.isFinite, amount >= 0, amount <= source.kilogramsPerAnimalPerDay,
                  recommendation.addedIngredient.id != source.id else {
                throw SimulationError.invalidPortion
            }
            return try calculator.calculate(
                profile: recommendation.before.profile,
                items: replacing(source: source, with: recommendation.addedIngredient,
                                 amount: amount, in: recommendation.before.items)
            )
        }
        
        private func targets(_ result: RationCalculationResult) -> [Double?] {
            let requirements = result.requirements
            let protein = requirements.crudeProteinPercent > 0
            ? result.nutrients.crudeProteinPercent / requirements.crudeProteinPercent : nil
            let tdn: Double?
            if let actual = result.nutrients.totalDigestibleNutrientsPercent,
               let minimum = requirements.totalDigestibleNutrientsPercent, minimum > 0 {
                tdn = actual / minimum
            } else {
                tdn = nil
            }
            return [protein, tdn]
        }
        
        private func preservesKnownTargets(_ before: [Double?], _ after: [Double?]) -> Bool {
            zip(before, after).allSatisfy { start, end in
                guard let start else { return true }
                guard let end else { return false }
                return end >= min(start, 1) - tolerance
            }
        }
        
        private func improves(_ before: [Double?], _ after: [Double?]) -> Bool {
            zip(before, after).contains { start, end in
                guard let end else { return false }
                guard let start else { return true }
                return min(end, 1) > min(start, 1) + tolerance
            }
        }
        
        private func deficit(_ result: RationCalculationResult) -> Double {
            targets(result).compactMap { $0 }.reduce(0) { $0 + max(0, 1 - $1) }
        }
        
        private func isBetter(_ lhs: RationRecommendation, than rhs: RationRecommendation, season: RationSeason?) -> Bool {
            if lhs.meetsTargets != rhs.meetsTargets { return lhs.meetsTargets }
            let leftUnknown = targets(lhs.after).filter { $0 == nil }.count
            let rightUnknown = targets(rhs.after).filter { $0 == nil }.count
            if leftUnknown != rightUnknown { return leftUnknown < rightUnknown }
            // Successful proposals are ranked by the smallest change even at a floating-point boundary.
            if !lhs.meetsTargets, deficit(lhs.after) != deficit(rhs.after) {
                return deficit(lhs.after) < deficit(rhs.after)
            }
            let leftPriority = season?.priority(for: lhs.addedIngredient) ?? 0
            let rightPriority = season?.priority(for: rhs.addedIngredient) ?? 0
            if leftPriority != rightPriority { return leftPriority > rightPriority }
            if lhs.replacedKilograms != rhs.replacedKilograms {
                return lhs.replacedKilograms < rhs.replacedKilograms
            }
            return lhs.id < rhs.id
        }
        
        private func replacing(
            source: RationItem, with candidate: FeedIngredient, amount: Double, in items: [RationItem]
        ) -> [RationItem] {
            var updated = items
            let index = updated.firstIndex { $0.id == source.id }!
            updated[index].kilogramsPerAnimalPerDay = max(0, source.kilogramsPerAnimalPerDay - amount)
            if let destination = updated.firstIndex(where: { $0.id == candidate.id }) {
                updated[destination].kilogramsPerAnimalPerDay += amount
            } else {
                updated.append(RationItem(ingredient: candidate, kilogramsPerAnimalPerDay: amount))
            }
            return updated.filter { $0.kilogramsPerAnimalPerDay > 0 }
        }
    }
