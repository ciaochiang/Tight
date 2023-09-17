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

class MainViewModel: ObservableObject {
  @Published var healthStoreManager: HealthStoreManager
  @Published var isHeartRateAuthoized: HKAuthorizationStatus = .notDetermined
  
  var cancellable : AnyCancellable?
  
  init() {
    let dependency = HealthStoreManagerDependencyImp(logger: Logger(configuration: AppConfiguration.loggerConfig))
    healthStoreManager = HealthStoreManager(dependency: dependency)
    
    checkAllAuthoizationStatus()
    cancellable = healthStoreManager.objectWillChange.sink { [weak self] (_) in
      self?.objectWillChange.send()
    }
  }
  
  func checkAllAuthoizationStatus() {
    isHeartRateAuthoized = healthStoreManager.checkIsAuthorized(objectType: .heartRate)
    if isHeartRateAuthoized == .sharingAuthorized {
      print("sharing authorized")
    } else if isHeartRateAuthoized == .sharingDenied {
      print("sharing denied")
    } else {
      print("not determined")
    }
  }
}
