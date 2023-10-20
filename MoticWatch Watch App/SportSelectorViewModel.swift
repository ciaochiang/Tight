//
//  SportSelectorViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import SwiftUI

protocol SportSelectorViewModelDependency {
    var logger: CustomLogger  { get }
    var sportProvider: SportProvider { get }
}

class SportSelectorViewModelDependencyImp: SportSelectorViewModelDependency {
    var logger: CustomLogger
    var sportProvider: SportProvider
    
    init(logger: CustomLogger, sportProvider: SportProvider) {
        self.logger = logger
        self.sportProvider = sportProvider
    }
}

class SportSelectorViewModel: ObservableObject {
    var dependency: SportSelectorViewModelDependency
    @Published var allSports: [Sport] = []
    
    init(dependency: SportSelectorViewModelDependency) {
        self.dependency = dependency
    }
    
    func fetchAllSports() {
        dependency.logger.log(level: .debug, message: "fetch all sports")
        dependency.sportProvider.fetchAllSports { [weak self] sports in
            self?.allSports = sports
        }
    }
}
