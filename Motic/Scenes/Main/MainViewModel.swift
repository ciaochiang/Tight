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
    var activitySessionManager: ActivitySessionManager { get }
    var logger: CustomLogger { get }
}

class MainViewModelDependencyImp: MainViewModelDependency {
    var preferenceManager: PreferenceManager
    var activitySessionManager: ActivitySessionManager
    var logger: CustomLogger
  
    init(preferenceManager: PreferenceManager,
         activtiySessionManager: ActivitySessionManager,
         logger: CustomLogger) {
        self.preferenceManager = preferenceManager
        self.activitySessionManager = activtiySessionManager
        self.logger = logger
    }
}

class MainViewModel: ObservableObject {
    var dependency: MainViewModelDependency
    @Published var healthStoreManager: HealthStoreManager
    @Published var user: BaseUser?
    @Published var activities: [Activity] = []
    @Published var lastestActivites: [Activity] = []
    @Published var selectedActivity: Activity?
    @Published var weeklySummary: WeeklySummary = WeeklySummary(totalElapsedTime: 0, totalDistanceKilometers: 0, averageSpeed: 0, activities: [])
    @Published var isSessionRunning: Bool = false
    @Binding var isRecordViewPresented: Bool
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    var name: String {
        let firstName = user?.firstName ?? ""
        let lastName = user?.lastName ?? ""
        return "\(firstName) \(lastName)"
    }
  
    init(dependency: MainViewModelDependency, isRecordViewPresented: Binding<Bool>) {
        self.dependency = dependency
        _isRecordViewPresented = isRecordViewPresented
        
        let storeDependency = HealthStoreManagerDependencyImp(logger: dependency.logger)
        healthStoreManager = HealthStoreManager(dependency: storeDependency)
        
        Task {
            do {
                self.weeklySummary = try await getWeeklySummary()
            } catch {
                dependency.logger.log(error.localizedDescription, level: .error)
            }
        }
      
        // Get current user
        let accountManager = AccountManager.shared
        user = accountManager.currentUser
        
        // Temp
        user?.age = 36
    }
    
    func getWeeklySummary() async throws -> WeeklySummary {
        let period = Date.thisWeek
        dependency.logger.log("\(period)", level: .info)
        
        let activities = try await healthStoreManager.getActivties(from: period.start, to: period.end)
        let workouts = activities.map { $0.workout }

        let totalDistanceKilometers = healthStoreManager.getTotalDistance(from: workouts)
        let totalElapsedTime = healthStoreManager.getTotalDuration(from: workouts)
        let averageSpeed = healthStoreManager.getAvgSpeed(totalDistance: totalDistanceKilometers, totalDuration: totalElapsedTime)
        
        return WeeklySummary(totalElapsedTime: totalElapsedTime,
                             totalDistanceKilometers: totalDistanceKilometers,
                             averageSpeed: averageSpeed, 
                             activities: activities)
    }
}

struct WeeklySummary {
    var totalElapsedTime: TimeInterval
    var totalDistanceKilometers: Double
    var averageSpeed: TimeInterval
    var activities: [Activity]
    var latestActivites: [Activity]
    
    init(totalElapsedTime: TimeInterval, totalDistanceKilometers: Double, averageSpeed: TimeInterval, activities: [Activity]) {
        self.totalElapsedTime = totalElapsedTime
        self.totalDistanceKilometers = totalDistanceKilometers
        self.averageSpeed = averageSpeed
        self.activities = activities
        self.latestActivites = Array(activities.prefix(3))
    }
}
