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
    
    static func thisMonth() -> (from: Date, end: Date) {
        // Retrieve this month activities
        let calendar = Calendar.current
        // Get the date components for the current date
        let components = calendar.dateComponents([.year, .month], from: Date())

        // Create the start date by setting the day and time components to the minimum
        var startComponents = components
        startComponents.day = 1
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 0

        // Create the end date by setting the day to the last day of the month and time components to the maximum
        var endComponents = components
        endComponents.month! += 1
        endComponents.day = 0
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59

        // Get the start date and end date
        if let startDate = calendar.date(from: startComponents),
           let endDate = calendar.date(from: endComponents) {
            return (startDate, endDate)
        } else {
            return (Date(), Date())
        }
    }
}
