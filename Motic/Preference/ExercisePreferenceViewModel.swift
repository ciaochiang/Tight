//
//  ExercisePreferenceViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/19.
//

import Foundation
import SwiftUI

protocol ExercisePreferenceViewModelDependency {
    var logger: CustomLogger { get }
}

class ExercisePreferenceViewModelDependencyImp: ExercisePreferenceViewModelDependency {
    var logger: CustomLogger
  
    init(logger: CustomLogger) {
        self.logger = logger
    }
}

class ExercisePreferenceViewModel: ObservableObject {
    var dependency: ExercisePreferenceViewModelDependency
    @Published var allExercises: [ExerciseItem] = []
    
    init(dependency: ExercisePreferenceViewModelDependency) {
        self.dependency = dependency
    }
}
