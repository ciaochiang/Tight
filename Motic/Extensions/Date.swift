//
//  Date.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/25.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        // Create a Calendar instance
        let calendar = Calendar.current

        // Create a DateComponents object with the year, month, and day
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        // Use the calendar to create a Date object
        if let date = calendar.date(from: dateComponents) {
            return date
        } else {
            return Date.now
        }
    }
}
