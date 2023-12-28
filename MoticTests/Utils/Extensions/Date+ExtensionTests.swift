//
//  Date+ExtensionTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
@testable import Motic

class DateExtensionTests: XCTestCase {
    
    func testDateFromYearMonthDay() {
        // Given
        let date = Date.from(year: 2023, month: 12, day: 28)
        
        // Then
        let formattedDate = date.format("yyyy-MM-dd")
        XCTAssertEqual(formattedDate, "2023-12-28")
    }
    
    func testIsToday() {
        // Given
        let today = Date()
        
        // Then
        XCTAssertTrue(today.isToday)
    }
    
    func testFetchWeek() {
        // Given
        let date = Date.from(year: 2023, month: 12, day: 28)
        
        // When
        let week = date.fetchWeek()
        
        // Then
        XCTAssertEqual(week.count, 7)
    }
    
    func testCreateNextWeek() {
        // Given
        let date = Date.from(year: 2023, month: 12, day: 28)
        
        // When
        let nextWeek = date.createNextWeek()
        
        // Then
        XCTAssertEqual(nextWeek.count, 7)
        XCTAssertEqual(nextWeek[0].date.isSameDay(as: Date.from(year: 2023, month: 12, day: 24)), true)
    }
    
    func testCreatePreviousWeek() {
        // Given
        let date = Date.from(year: 2023, month: 12, day: 28)
        
        // When
        let previousWeek = date.createPreviousWeek()
        
        // Then
        XCTAssertEqual(previousWeek.count, 7)
        print("date: \(previousWeek[0].date)")
        XCTAssertEqual(previousWeek[0].date.isSameDay(as: Date.from(year: 2023, month: 12, day: 24)), true)
    }
}

