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
    
    static var thisWeek: (start: Date, end: Date) {
        let currentDate = Date()
        var calendar = Calendar.current
        calendar.firstWeekday = 2   // Start from Monday

        // Get the start date of the current week
        let dateComponent = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        print(calendar.date(from: dateComponent))
        guard let startDateOfWeek = calendar.date(from: dateComponent),
                let endDateOfWeek = calendar.date(byAdding: .day, value: 6, to: startDateOfWeek) else {
            return (start: Date(), end: Date())
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
            return (start: startDateOfWeek, end: endDateOfWeek)
        }
        
        return (start: startDate, end: endDate)
    }
}
