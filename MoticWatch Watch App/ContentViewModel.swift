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
    
    var connectivity: WatchConnectivityProvider = WatchConnectivityProvider()
    
    @Published var sports: [Sport] = []


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
    
    func fetchAllSports() {
        connectivity.send(message: ["request": "fetchSports"]) { response in
            if let values = response["reply"] as? [[String: Any]] {
                let allSports = values.map { Sport(id: $0["id"] as? Int ?? 0, description: $0["description"] as? String ?? "") }
                self.sports = allSports
                print("all sports: \(allSports)")
            }
        }
    }
}
