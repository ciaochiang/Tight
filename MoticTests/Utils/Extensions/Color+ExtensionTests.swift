//
//  Color+ExtensionTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
@testable import Motic
import SwiftUI

final class ColorExtensionTests: XCTestCase {
    
    func testComponentsForUIColor() {
        // Given
        #if canImport(UIKit)
        let color = Color(UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8))
        
        // When
        let components = color.components
        
        // Then
        XCTAssertEqual(components.r, 0.2)
        XCTAssertEqual(components.g, 0.4)
        XCTAssertEqual(components.b, 0.6)
        XCTAssertEqual(components.a, 0.8)
        #endif
    }
    
    func testComponentsForNSColor() {
        // Given
        #if canImport(AppKit)
        let color = Color(NSColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8))
        
        // When
        let components = color.components
        
        // Then
        XCTAssertEqual(components.r, 0.2)
        XCTAssertEqual(components.g, 0.4)
        XCTAssertEqual(components.b, 0.6)
        XCTAssertEqual(components.a, 0.8)
        #endif
    }
}
