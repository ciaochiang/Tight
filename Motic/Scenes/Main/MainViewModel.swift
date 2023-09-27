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
  var preferenceManager: PreferenceManager { get }
  var logger: Logger { get }
}

class MainViewModelDependencyImp: MainViewModelDependency {
  var preferenceManager: PreferenceManager
  var logger: Logger
  
  init(preferenceManager: PreferenceManager, logger: Logger) {
    self.preferenceManager = preferenceManager
    self.logger = logger
  }
}

class MainViewModel: ObservableObject {
    var dependency: MainViewModelDependency
    @Published var healthStoreManager: HealthStoreManager
    @Published var isHeartRateAuthorized: Bool = false
    @Published var user: BaseUser?
    @Published var activities: [Activity] = []
    @Published var selectedActivity: Activity?
    @Published var totalDuration: TimeInterval = 0.0
    @Published var totalDistanceKilometers: Double = 0.0
    @Published var avgSpeed: Double = 0.0
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
        }
        
        let thisMonth = Date.thisMonth()
        Task {
            do {
                let activities = try await healthStoreManager.getActivties(from: thisMonth.from, to: thisMonth.end)
                let workouts = activities.map { $0.workout }
                
                let totalDistanceKilometers = healthStoreManager.getTotalDistance(from: workouts)
                let totalDuration = healthStoreManager.getTotalDuration(from: workouts)
                let avgSpeed = healthStoreManager.getAvgSpeed(totalDistance: totalDistanceKilometers, totalDuration: totalDuration)
                
                await MainActor.run(body: {
                    self.totalDistanceKilometers = totalDistanceKilometers
                    self.totalDuration = totalDuration
                    self.avgSpeed = avgSpeed
                })
            }
        }
      
        // Retrieve this month activities
        let fromDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())! // One month ago
        let toDate = Date()
        Task {
            do {
                let activities = try await healthStoreManager.getActivties(from: fromDate, to: toDate)
                
                await MainActor.run(body: {
                    self.activities = activities
                })
            }
            catch let error {
                dependency.logger.log(error.localizedDescription, level: .error)
            }
        }
      
        // Get current user
        let accountManager = AccountManager.shared
        user = accountManager.currentUser
        
        // Temp
        user?.age = 36
    }
}
