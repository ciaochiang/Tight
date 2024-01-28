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
        // Create a date for testing (e.g., January 15, 2023)
        let testDate = Date.from(year: 2023, month: 1, day: 15)
        
        // Call fetchWeek with the test date
        let result = testDate.fetchWeek()
        
        // Ensure that the result contains 7 days
        XCTAssertEqual(result.count, 7)
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
