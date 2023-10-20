//
//  SportSelectorViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import SwiftUI

protocol SportSelectorViewModelDependency {
    var logger: Logger  { get }
    var sportProvider: SportProvider { get }
}

class SportSelectorViewModelDependencyImp: SportSelectorViewModelDependency {
    var logger: Logger
    var sportProvider: SportProvider
    
    init(logger: Logger, sportProvider: SportProvider) {
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
        dependency.sportProvider.fetchAllSports { [weak self] sports in
            self?.allSports = sports
        }
    }
}
