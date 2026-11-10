//
//  circleDot.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 09/11/26.
//

import SwiftUI

struct circleDot: View {
    var body: some View {
        Circle()
            .fill(AppColor.Primitive.Primary.shade500)
            .frame(width: 20, height: 20)
    }
}

#Preview {
    circleDot()
}
