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
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init()),
            .init(exericse: .benchPress, scheduledDate: .init())
        ]
    }
}

struct ScheduledExercise: Identifiable {
    var id: UUID = .init()
    var exericse: Exercise
    var scheduledDate: Date
    var isCompleted: Bool = false
}



