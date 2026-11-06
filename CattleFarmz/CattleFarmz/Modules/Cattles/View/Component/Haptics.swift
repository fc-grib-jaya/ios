//
//  Haptics.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import UIKit

enum Haptics {
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

