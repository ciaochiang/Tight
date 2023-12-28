//
//  TimeInterval+ExtensionTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
@testable import Motic

final class TimeIntervalExtensionTests: XCTestCase {

    func testFormatTimeInterval() {
        // Given
        let timeInterval: TimeInterval = 3660 // 1 hour and 1 minute
        
        // When
        let formattedTime = timeInterval.formatTimeInterval
        
        // Then
        XCTAssertEqual(formattedTime, "01:01:00")
    }
    
    func testShorterFormatInterval() {
        // Given
        let timeInterval: TimeInterval = 3660 // 1 hour and 1 minute
        
        // When
        let formattedTime = timeInterval.shorterFormatInterval
        
        // Then
        XCTAssertEqual(formattedTime, "1h 01m")
    }
    
    func testFormatAvgSpeedTimeInterval() {
        // Given
        let timeInterval: TimeInterval = 125 // 2 minutes and 5 seconds
        
        // When
        let formattedTime = timeInterval.formatAvgSpeedTimeInterval
        
        // Then
        XCTAssertEqual(formattedTime, "2'05\"")
    }
    
    func testFormatIntervalToMinutesSeconds() {
        // Given
        let timeInterval: TimeInterval = 125 // 2 minutes and 5 seconds
        
        // When
        let formattedTime = timeInterval.formatIntervalToMinutesSeconds
        
        // Then
        XCTAssertEqual(formattedTime, "02:05")
    }
}
