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
  private let dependency: HealthStoreManagerDependency
  private let healthStore = HKHealthStore()
  private var heartRateObserverQuery: HKObserverQuery?
  private var personalHeartRateZones: HeartRateZones
  
  @Published var latestHeartRate: HeartRateSample<HKQuantitySample, Double>
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
  func checkIsAuthorized(objectType: ObjectType) -> HKAuthorizationStatus {
    return healthStore.authorizationStatus(for: objectType.objectType)
  }
  
  func authorizeHealthKit(completion: @escaping (Bool) -> ()) {
    guard HKHealthStore.isHealthDataAvailable() else {
      self.isHealthKitAuthorized = false
      completion(true)
      return
    }
    
    healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead) { (success, error) in
      if success {
        self.isHealthKitAuthorized = true
      } else {
        // Handle authorization failure
        self.isHealthKitAuthorized = false
      }
      
      completion(true)
    }
  }
}

// MARK: Heart Rate Function
extension HealthStoreManager {
  func stopObserveHeartRateSamples() {
    if let observerQuery = heartRateObserverQuery {
      healthStore.stop(observerQuery)
    }
  }
  
  func startObserveHeartRateSamples() {
    let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
            
    if let observerQuery = heartRateObserverQuery {
      healthStore.stop(observerQuery)
    }
      
    heartRateObserverQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
      if let error = error {
        print("Error: \(error.localizedDescription)")
        return
      }
      
      self.fetchLatestHeartRateSample { sample in
        guard let sample = sample else {
          return
        }
        
        DispatchQueue.main.async {
          self.latestHeartRate = HeartRateSample(sample: sample)
          self.currentZone = self.personalHeartRateZones.getCurrentZone(heartRate: self.latestHeartRate)
        }
      }
    }
    
    if let observerQuery = heartRateObserverQuery {
      healthStore.execute(observerQuery)
    }
  }
  
  func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
    guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
      completionHandler(nil)
      return
    }
    
    let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    let query = HKSampleQuery(sampleType: sampleType,
                              predicate: predicate,
                              limit: Int(HKObjectQueryNoLimit),
                              sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                    return
                                }
                                
                                completionHandler(results?[0] as? HKQuantitySample)
    }
    
    healthStore.execute(query)
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
                print("Error fetching workout sessions: \(error.localizedDescription)")
            }
        }
    }
    
    // Execute the query
    healthStore.execute(query)
  }
}

// MARK: Cycling
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
