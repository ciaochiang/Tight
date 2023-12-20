//
//  ExercisePreferenceViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/19.
//

import Foundation
import SwiftUI

protocol ExercisePreferenceViewModelDependency {
    var preferenceManager: PreferenceManager { get }
    var activitySessionManager: ActivitySessionManager { get }
    var logger: CustomLogger { get }
}


class ExercisePreferenceViewModelDependencyImp: ExercisePreferenceViewModelDependency {
    var preferenceManager: PreferenceManager
    var activitySessionManager: ActivitySessionManager
    var logger: CustomLogger
  
    init(preferenceManager: PreferenceManager,
         activtiySessionManager: ActivitySessionManager,
         logger: CustomLogger) {
        self.preferenceManager = preferenceManager
        self.activitySessionManager = activtiySessionManager
        self.logger = logger
    }
}

class ExercisePreferenceViewModel: ObservableObject {
    var dependency: ExercisePreferenceViewModelDependency
    
    init(dependency: ExercisePreferenceViewModelDependency) {
        self.dependency = dependency
    }
}
