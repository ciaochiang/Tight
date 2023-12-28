//
//  OffsetKeyTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
@testable import Motic
import SwiftUI

class OffsetKeyTests: XCTestCase {
    
    func testDefaultValue() {
        // Given
        let defaultValue = OffsetKey.defaultValue
        
        // Then
        XCTAssertEqual(defaultValue, CGFloat(0))
    }
    
    func testReduce() {
        // Given
        var value: CGFloat = 5
        let nextValue: () -> CGFloat = { 10 }
        
        // When
        OffsetKey.reduce(value: &value, nextValue: nextValue)
        
        // Then
        XCTAssertEqual(value, CGFloat(10))
    }
}
