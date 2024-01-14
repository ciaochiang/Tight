//
//  Date+ExtensionTests.swift
//  TightTests
//
//  Created by Ciao Chiang on 2024/1/14.
//

import XCTest
@testable import Tight

final class Date_ExtensionTests: XCTestCase {

    func testIsToday() {
        // Create a date that is today
        let today = Date()
        XCTAssertTrue(today.isToday)
        
        // Create a date that is not today
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertFalse(yesterday.isToday)
    }
    
    func testIsSameDay() {
        let date1 = Date.from(year: 2023, month: 1, day: 15)
        let date2 = Date.from(year: 2023, month: 1, day: 15)
        XCTAssertTrue(date1.isSameDay(as: date2))
        
        let date3 = Date.from(year: 2023, month: 1, day: 15)
        let date4 = Date.from(year: 2023, month: 1, day: 16)
        XCTAssertFalse(date3.isSameDay(as: date4))
    }
    
    func testFetchWeek() {
        let date = Date.from(year: 2023, month: 1, day: 15) // A random date
        
        let week = date.fetchWeek()
        
        // Ensure the result contains 7 days
        XCTAssertEqual(week.count, 7)
        
        // Verify that the first day is the start of the week (Monday or Sunday, depending on your locale)
        XCTAssertEqual(Calendar.current.component(.weekday, from: week[0].date), Calendar.current.firstWeekday)
        
        // Verify that the last day is 6 days after the first day
        XCTAssertEqual(Calendar.current.component(.day, from: week[6].date), Calendar.current.component(.day, from: week[0].date) + 6)
    }
    
    func testCreateNextWeek() {
        let date = Date.from(year: 2023, month: 1, day: 15) // A random date
        
        let nextWeek = date.createNextWeek()
        
        // Ensure the result contains 7 days
        XCTAssertEqual(nextWeek.count, 7)
        
        // Verify that the first day is one day after the input date
        XCTAssertEqual(Calendar.current.component(.day, from: nextWeek[0].date), 15)
    }
    
    func testCreatePreviousWeek() {
        let date = Date.from(year: 2023, month: 1, day: 15) // A random date
        
        let previousWeek = date.createPreviousWeek()
        
        // Ensure the result contains 7 days
        XCTAssertEqual(previousWeek.count, 7)
        
        // Verify that the first day is one day before the input date
        XCTAssertEqual(Calendar.current.component(.day, from: previousWeek[0].date), 8)
    }
}
