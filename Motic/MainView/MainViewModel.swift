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
  @Published var healthStoreManager: HealthStoreManager = HealthStoreManager()
  @Published var isHeartRateAuthoized: HKAuthorizationStatus = .notDetermined
  
  var cancellable : AnyCancellable?
  
  init() {
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
  
  
//  func checkHKSampleTypeAuthorization(with sampleType: HealthStoreManager.SampleType) ->  {
//    let status = healthStoreManager.checkIsAuthorized(with: sampleType)
//    if status == .notDetermined {
//      print("not determined")
//    } else if status == .sharingAuthorized {
//      print("sharing authorized")
//    } else if status == .sharingDenied {
//      print("sharing denied")
//    } else {
//      // do nothing
//    }
//  }
}
