//
//  HealthStoreManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import HealthKit
import SwiftUI

protocol HealthStoreManagerDependency {
  var logger: Logger { get }
}

class HealthStoreManagerDependencyImp: HealthStoreManagerDependency {
  var logger: Logger
  
  init(logger: Logger) {
    self.logger = logger
  }
}

class HealthStoreManager: NSObject, ObservableObject {
  let dependency: HealthStoreManagerDependency
  let healthStore = HKHealthStore()
  var personalHeartRateZones: HeartRateZones
  
  @Published var latestHeartRate: HeartRateSample<HKQuantitySample, Double> {
    didSet {
      self.currentZone = self.personalHeartRateZones.zones.first(where: { $0.heartRateRange.contains(Int(latestHeartRate.value))})
    }
  }
  @Published var currentZone: Zone?
  @Published var activities: [HKWorkout] = []

  @AppStorage("isHealthKitAuthorized") var isHealthKitAuthorized: Bool = false
  
  let infoToRead = Set([
    HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
    HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
    HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKSampleType.quantityType(forIdentifier: .heartRate)!,
    HKSampleType.workoutType()
  ])
              
  let infoToWrite = Set([
    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
    HKObjectType.workoutType()
  ])
  
  enum ObjectType {
    case biologicalSex
    case dateOfBirth
    case activeEnergyBurned
    case distanceWalkingRunning
    case heartRate
    
    var objectType: HKObjectType {
      switch self {
      case .biologicalSex: return HKSampleType.characteristicType(forIdentifier: .biologicalSex)!
      case .dateOfBirth: return HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!
      case .activeEnergyBurned: return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
      case .distanceWalkingRunning: return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
      case .heartRate: return HKSampleType.quantityType(forIdentifier: .heartRate)!
      }
    }
  }
  
  init(dependency: HealthStoreManagerDependency) {
    self.dependency = dependency
    
    let hearRate = HeartRateSample<HKQuantitySample, Double>()
    self.latestHeartRate = hearRate
    personalHeartRateZones = HeartRateZones(maxHeartRate: 190, age: 36)
    
    let zone = personalHeartRateZones.getCurrentZone(heartRate: hearRate)
    currentZone = zone
  }
}

// MARK: Authorization Functions
extension HealthStoreManager {
  /// Get specific authorization status thorugh custom ObjectType enum
  ///
  /// - Parameter objectType: This is a custom enum of HKObjectType
  /// - Returns: Returns a HKAuthorizationStatus
  func getAthorizationStatus(objectType: ObjectType) -> HKAuthorizationStatus {
    return healthStore.authorizationStatus(for: objectType.objectType)
  }
  
  func authorizeHealthKit(completion: @escaping (Bool) -> ()) {
    guard HKHealthStore.isHealthDataAvailable() else {
      self.isHealthKitAuthorized = false
      self.dependency.logger.log("Health data is not available.", level: .info)
      completion(true)
      return
    }
    
    healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead) { (success, error) in
      if success {
        self.isHealthKitAuthorized = true
        self.dependency.logger.log("Health store data sharing is authorized.", level: .info)
      } else {
        // Handle authorization failure
        self.isHealthKitAuthorized = false
        self.dependency.logger.log("Health store data sharing is denied.", level: .info)
      }
      
      completion(true)
    }
  }
}

// MARK: Workout Functions
extension HealthStoreManager {
  func retrieveOneMonthActivities() {
    // Test
    let fromDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())! // One month ago
    let toDate = Date()
    retrieveWorkoutSessions(from: fromDate, to: toDate)
  }
  
  func retrieveWorkoutSessions(from: Date, to: Date) {
    let workoutType = HKSampleType.workoutType()
    let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)

    // Create a query to fetch workout sessions
    let query = HKSampleQuery(sampleType: workoutType,
                              predicate: predicate,
                              limit: Int(HKObjectQueryNoLimit),
                              sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
      if let workoutSessions = results as? [HKWorkout] {
        self.dependency.logger.log("Workout activities is fetching succeed", level: .info)
        DispatchQueue.main.async {
          self.activities = workoutSessions
        }
      
        for workoutSession in workoutSessions {
            // Process each workout session
            print("Workout Session: \(workoutSession)")
        }
      } else {
        // Handle the case where no workout sessions were found or an error occurred
        if let error = error {
          self.dependency.logger.log("Error fetching workout session: \(error.localizedDescription)", level: .error)
        }
      }
    }
    
    // Execute the query
    healthStore.execute(query)
  }
}

// MARK: Cycling Fucntions
extension HealthStoreManager {
  func calculateWattage(forCyclingActivity cyclingActivity: HKWorkout) -> Double? {
    // Check if the activity type is cycling
    guard cyclingActivity.workoutActivityType == .cycling else {
      return nil
    }
    
    // Extract relevant data from the workout
    if let distance = cyclingActivity.totalDistance?.doubleValue(for: .meter()) {
        
      // Constants for typical cycling calculations
      let riderWeightKg = 70.0  // Rider's weight in kilograms
      let rollingResistanceCoefficient = 0.004  // Typical value for road cycling
        
      // Calculate speed in meters per second
      let speed = distance / cyclingActivity.duration
        
      // Calculate power in watts (wattage)
      let power = (0.5 * rollingResistanceCoefficient * speed * speed * riderWeightKg * 9.81)
      
      return power
    }
    
    return nil
  }
}
