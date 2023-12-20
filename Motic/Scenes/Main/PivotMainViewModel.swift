//
//  PivotMainViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import Foundation
import SwiftUI

class PivotMainViewModel: ObservableObject {
    @Published var scheduledExercises: [ScheduledExerciseItem] = []
    
    init() {
        scheduledExercises = [
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1"),
            .init(id: 0, name: "test 1")
        ]
    }
}



