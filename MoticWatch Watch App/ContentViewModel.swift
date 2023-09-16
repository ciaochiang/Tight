//
//  ContentViewModel.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/15.
//

import Foundation
import HealthKit

class ContentViewModel: ObservableObject {
  var supportedActivityTypes: [HKWorkoutActivityType] = [.cycling, .running]

//  @Published var workoutSessionIsStarted: Bool = false
  
//  func toggle(isStarted: Bool = false) {
//    DispatchQueue.main.async {
//      self.isStarted = isStarted
//    }
//  }
  
  func getActivityName(activityType: HKWorkoutActivityType) -> String {
    switch activityType {
    case .cycling: return "Cycling"
    case .running: return "Running"
    default: return "Unknown"
    }
  }
}
