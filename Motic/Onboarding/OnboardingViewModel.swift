//
//  OnboardingViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
  @Published var state: OnboardingState = .welcome
  
  enum OnboardingState: Int, CaseIterable, Hashable {
    case welcome
    case requestHealthKitPermission
    case requestLocationPermission
    case requestNotificationPermission
    case done
    
    init(stateRawValue: Int) {
      switch stateRawValue {
      case 0: self = .welcome
      case 1: self = .requestHealthKitPermission
      case 2: self = .requestLocationPermission
      case 3: self = .requestNotificationPermission
      case 4: self = .done
      default: self = .welcome
      }
    }
    
    var buttonTitle: String {
      switch self {
      case .welcome: return "Get Started"
      case .requestHealthKitPermission: return "Connect HealthKit"
      case .requestLocationPermission: return "Turn On Location"
      case .requestNotificationPermission: return "Turn On Notification"
      case .done: return "Done"
      }
    }
  }
}

// MARK: FUNCTIONS
extension OnboardingViewModel {
  func handleButtonAction(with state: OnboardingState) {
    switch state {
    case .requestHealthKitPermission: requestHealthKitPermission()
    case .requestLocationPermission: requestLocationPermission()
    case .requestNotificationPermission: requestNotificationPermission()
    default: nextState()
    }
  }
  
  private func requestHealthKitPermission() {
    let healthStoreManager = HealthStoreManager()
    healthStoreManager.authorizeHealthKit { [weak self] completed in
      self?.nextState()
    }
  }
  
  private func requestLocationPermission() {
    let locationManager = LocationManager()
    locationManager.requestLocationPermission()
    nextState()
  }
  
  private func requestNotificationPermission() {
    let notificationManager = NotificationManager()
    notificationManager.requestNotificationAuthorization { [weak self] completed in
      self?.nextState()
    }
  }
  
  private func nextState() {
    guard state.rawValue < 4 else {
      return
    }
    
    var stateRawValue = state.rawValue
    stateRawValue += 1
    DispatchQueue.main.async {
      withAnimation {
        self.state = OnboardingState(stateRawValue: stateRawValue)
      }
    }
  }
}
