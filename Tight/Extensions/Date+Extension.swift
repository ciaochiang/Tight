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
    
    var startOfMonth: Date {
        let calendar = Calendar.current

        // Get the start date of the current month
        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) {
            return startOfMonth
        } else {
            return .now
        }
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
                
        // Get the end date of the current month
        if let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
            return endOfMonth
        }
        
        return .now
    }
    
    func format(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    var today: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    
    /// Checking whether the Date is Today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current

        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date)

        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    } 
    
    /// Fetching Week Based  on given date
    func fetchWeek(_ date: Date = .init()) -> [Weekday] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [Weekday] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
                
        return week
    }
    
    /// Create next week, based on the last current week's date
    func createNextWeek() -> [Weekday] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        
        return fetchWeek(nextDate)
    }
    
    /// Create previous week, based on the last current week's date
    func createPreviousWeek() -> [Weekday] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        
        return fetchWeek(previousDate)
    }
    
    struct Weekday: Identifiable, Equatable {
        var id: UUID = .init()
        var date: Date
    }
}
