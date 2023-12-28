//
//  PivotMainViewModelTests.swift
//  MoticTests
//
//  Created by Ciao Chiang on 2023/12/28.
//

import XCTest
import CoreData
import SwiftData
@testable import Motic // Replace with your actual app module

class PivotMainViewModelTests: XCTestCase {
    var viewModel: PivotMainViewModel!
        
    override func setUp() {
        super.setUp()
        
        // Set up an in-memory CoreData stack
        let prviewContainer = PreviewContainer([Plan.self, ArrangedExercise.self, Tag.self], isStoredInMemoryOnly: true)
        let context = ModelContext(prviewContainer.container)
        viewModel = PivotMainViewModel(context: context)
    }
    
    func testIncrementOrderNumber() {
        // Given
        let initialOrderNumber = viewModel.incrementOrderNumber()
        
        // When
        // Add an arranged exercise to the current plan
        let newExercise = ArrangedExercise(exercise: .none, 
                                           repetitions: 0,
                                           sets: 0,
                                           weight: 0,
                                           durationOfSet: 0,
                                           restIntevals: 0,
                                           order: initialOrderNumber,
                                           tags: [],
                                           isCompleted: false)
        newExercise.order = 0
        viewModel.currentPlan.arrangedExercises.append(newExercise)
        let updatedOrderNumber = viewModel.incrementOrderNumber()
        
        // Then
        XCTAssertEqual(newExercise.order, 0)
        XCTAssertEqual(initialOrderNumber, 0)
        XCTAssertEqual(updatedOrderNumber, 1)
    }
    
    func testFetchPlan() {
        // Given
        let initialPlan = viewModel.fetchPlan(by: .init())
        
        // Then
        XCTAssertNotNil(initialPlan)
    }
}
