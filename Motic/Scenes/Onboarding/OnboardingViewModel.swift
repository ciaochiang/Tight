//
//  OnboardingViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import Foundation
import SwiftUI
import CoreLocation

class OnboardingViewModel: ObservableObject {
    @Published var state: OnboardingState = .welcome
    @Published var currentIndex: Int = 0
    @Binding var isOnboardingCompleted: Bool
    
    init(isOnboardingCompleted: Binding<Bool>) {
        _isOnboardingCompleted = isOnboardingCompleted
    }
  
    enum OnboardingState: Int, CaseIterable, Hashable {
        case welcome
//        case requestHealthKitPermission
        case requestNotificationPermission
//        case requestLocationPermission
        
        init(stateRawValue: Int) {
            switch stateRawValue {
            case 0: self = .welcome
//            case 1: self = .requestHealthKitPermission
            case 1: self = .requestNotificationPermission
//            case 3: self = .requestLocationPermission
            default: self = .welcome
            }
        }
        
        static var count: Int {
            return OnboardingState.allCases.count
        }
    }
}

// MARK: FUNCTIONS
extension OnboardingViewModel {
  func handleButtonAction(with state: OnboardingState) {
      switch state {
      case .welcome: nextState()
//      case .requestHealthKitPermission: requestHealthKitPermission()
      case .requestNotificationPermission: requestNotificationPermission()
//      case .requestLocationPermission: requestLocationPermission()
      }
  }
  
  private func requestHealthKitPermission() {
      let logger = CustomLogger()
      let dependency = HealthStoreManagerDependencyImp(logger: logger)
      let healthStoreManager = HealthStoreManager(dependency: dependency)
      Task {
          await MainActor.run(body: {
              healthStoreManager.authorizeHealthKit { [weak self] _ in
                self?.nextState()
              }
          })
      }
  }
  
  private func requestLocationPermission() {
      let locationManager = CLLocationManager()
      locationManager.requestWhenInUseAuthorization()
      nextState()
  }
  
  private func requestNotificationPermission() {
      let notificationManager = NotificationManager()
      Task {
          await MainActor.run(body: {
              notificationManager.requestNotificationAuthorization { [weak self] completed in
                self?.nextState()
              }
          })
      }
  }
  
  private func nextState() {
      if state == .requestNotificationPermission {
          // go to main view
          isOnboardingCompleted = true
          return
      }
      
      guard state.rawValue < 3 else { return }
      
      var stateRawValue = state.rawValue
      stateRawValue += 1
      DispatchQueue.main.async {
          withAnimation {
              self.currentIndex = stateRawValue
              self.state = OnboardingState(stateRawValue: stateRawValue)
          }
      }
  }
}
