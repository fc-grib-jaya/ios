//
//  PageCount.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 19/11/26.
//

import SwiftUI

struct PageCount: View {
    let pageNum: Int
    let totalPage: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.Primitive.Primary.shade500.opacity(0.2), lineWidth: 5)
                
            Circle()
                .trim(
                    from: 0,
                    to: totalPage > 0
                        ? min(max(CGFloat(pageNum) / CGFloat(totalPage), 0), 1)
                        : 0
                )
                .stroke(
                    AppColor.Primitive.Primary.shade500,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: pageNum)
            
            Text("\(pageNum)/\(totalPage)")
                .font(AppFont.mediumSubheadline).bold()
        }
        .frame(width: 40, height: 40)
    }
}

#Preview {
    PageCount(pageNum: 1, totalPage: 3)
}
