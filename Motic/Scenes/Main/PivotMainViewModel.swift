//
//  PivotMainViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import Foundation
import SwiftUI
import SwiftData

class PivotMainViewModel: ObservableObject {
    @Published var scheduledExercises: [ScheduledExercise] = []
    
    init() {
        scheduledExercises = [
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init()),
            .init(name: "test 1", scheduledDate: .init())
        ]
    }
}

struct ScheduledExercise: Identifiable {
    var id: UUID = .init()
    var name: String
    var scheduledDate: Date
    var isCompleted: Bool = false
}



