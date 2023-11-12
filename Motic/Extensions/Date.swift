//
//  Date.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/25.
//

import Foundation

typealias TimePeriod = (start: Date, end: Date)

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
    
    static var thisWeek: TimePeriod {
        let currentDate = Date()
        var calendar = Calendar.current
        calendar.firstWeekday = 2   // Start from Monday

        // Get the start date of the current week
        let dateComponent = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        guard let startDateOfWeek = calendar.date(from: dateComponent),
                let endDateOfWeek = calendar.date(byAdding: .day, value: 6, to: startDateOfWeek) else {
            return TimePeriod(start: Date(), end: Date())
        }
        
        var fromDateComponent = calendar.dateComponents([.hour, .minute, .second], from: startDateOfWeek)
        var endDateComponent = calendar.dateComponents([.hour, .minute, .second], from: endDateOfWeek)
        
        fromDateComponent.hour = 0
        fromDateComponent.minute = 0
        fromDateComponent.second = 0
        
        endDateComponent.hour = 23
        endDateComponent.minute = 59
        endDateComponent.second = 59
        
        guard let startDate = calendar.date(from: dateComponent),
                let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
            return TimePeriod(start: startDateOfWeek, end: endDateOfWeek)
        }
        
        return (start: startDate, end: endDate)
    }
}
