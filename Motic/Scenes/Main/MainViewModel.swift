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
  @Published var isHeartRateAuthoized: HKAuthorizationStatus = .notDetermined
  
  var cancellable : AnyCancellable?
  
  init(dependency: MainViewModelDependency) {
    self.dependency = dependency
    
    let storeDependency = HealthStoreManagerDependencyImp(logger: dependency.logger)
    healthStoreManager = HealthStoreManager(dependency: storeDependency)
    
    checkAllAuthoizationStatus()
    cancellable = healthStoreManager.objectWillChange.sink { [weak self] (_) in
      self?.objectWillChange.send()
    }
  }
  
  func checkAllAuthoizationStatus() {
    isHeartRateAuthoized = healthStoreManager.checkIsAuthorized(objectType: .heartRate)
    if isHeartRateAuthoized == .sharingAuthorized {
      dependency.logger.log("Health store sharing is authorized", level: .info)
    } else if isHeartRateAuthoized == .sharingDenied {
      dependency.logger.log("Health store sharing is denied", level: .warning)
    } else {
      dependency.logger.log("Health store sharing is not determined", level: .warning)
    }
  }
}
