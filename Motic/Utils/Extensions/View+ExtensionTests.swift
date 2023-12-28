//
//  View+ExtensionTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
import SwiftUI
@testable import Motic

final class ViewExtensionTests: XCTestCase {
    struct TestView: View {
        var body: some View {
            Text("Test")
        }
    }
    
    func testIsSameDate() {
        // Given
        let date1 = Date()
        let date2 = Date()
        
        // When
        let areDatesSame = TestView().isSameDate(date1, date2)
        
        // Then
        XCTAssertTrue(areDatesSame)
    }
}
