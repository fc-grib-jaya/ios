//
//  FormatDate.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 07/11/26.
//

import Foundation

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "id_ID")
    formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
    formatter.dateFormat = "d MMMM yyyy, HH.mm 'WIB'"

    return formatter.string(from: date)
}
