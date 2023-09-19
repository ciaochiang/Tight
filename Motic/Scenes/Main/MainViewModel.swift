//
//  MainViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import Foundation
import HealthKit
import SwiftUI
import Combine

protocol MainViewModelDependency {
  var logger: Logger { get }
}

class MainViewModelDependencyImp: MainViewModelDependency {
  var logger: Logger
  
  init(logger: Logger) {
    self.logger = logger
  }
}

class MainViewModel: ObservableObject {
  var dependency: MainViewModelDependency
  @Published var healthStoreManager: HealthStoreManager
  @Published var isHeartRateAuthorized: Bool = false
  @Published var user: BaseUser?
  
  var cancellable : AnyCancellable?
  
  init(dependency: MainViewModelDependency) {
    self.dependency = dependency
    
    let storeDependency = HealthStoreManagerDependencyImp(logger: dependency.logger)
    healthStoreManager = HealthStoreManager(dependency: storeDependency)
    
    cancellable = healthStoreManager.objectWillChange.sink { [weak self] (_) in
      DispatchQueue.main.async {
        self?.objectWillChange.send()
      }
    }

    // Start observe heart rate
    let heartRateAuthorizationStatus = healthStoreManager.getAthorizationStatus(objectType: .heartRate)
    if heartRateAuthorizationStatus == .sharingAuthorized {
      isHeartRateAuthorized = true
      healthStoreManager.startObserveHeartRateSamples()
    }
    
    // Retrieve Workout Sesssions
    healthStoreManager.retrieveOneMonthActivities()
    
    // Get current user
    let accountManager = AccountManager.shared
    user = accountManager.currentUser
  }
}
