//
//  SportSelectorViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import Foundation
import SwiftUI

protocol SportSelectorViewModelDependency {
    var logger: Logger  { get }
}

class SportSelectorViewModelDependencyImp: SportSelectorViewModelDependency {
    var logger: Logger
    init(logger: Logger) {
        self.logger = logger
    }
}

class SportSelectorViewModel: ObservableObject {
    var dependency: SportSelectorViewModelDependency
    
    init(dependency: SportSelectorViewModelDependency) {
        self.dependency = dependency
    }
}
