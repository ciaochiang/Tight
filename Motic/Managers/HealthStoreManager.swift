//
//  HealthStoreManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import HealthKit
import SwiftUI

protocol BaseSample {
  associatedtype SampleType
  associatedtype SampleValueType
  
  var quantitySameple: SampleType { get }
  var value: SampleValueType { get }
  var startDate: Date { get }
  var endDate: Date { get }
  
  func getTimeString(from: Date, with timezone: TimeZone) -> String
}

extension BaseSample {
  func getTimeString(from: Date, with timezone: TimeZone = .current) -> String {
    let dateFormmater = DateFormatter()
    dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormmater.timeZone = timezone
    return dateFormmater.string(from: from)
  }
}

struct HeartRateSample<T, U>: BaseSample {
  typealias SampleType = HKQuantitySample
  typealias SampleValueType = Double
  
  var quantitySameple: HKQuantitySample
  var value: Double
  var startDate: Date
  var endDate: Date
  
  init() {
    quantitySameple = HKQuantitySample(type: HKQuantityType(.heartRate),
                                       quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: 0.0),
                                       start: Date(),
                                       end: Date())
    value = 0.0
    startDate = Date()
    endDate = Date()
  }
  
  init(sample: HKQuantitySample) {
    self.quantitySameple = sample
    
    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
    let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
    print("Heart Rate: \(heartRate)")
    
    self.value = heartRate
    self.startDate = sample.startDate
    self.endDate = sample.endDate
  }
}

class HealthStoreManager: NSObject, ObservableObject {
  private let healthStore = HKHealthStore()
  private var heartRateObserverQuery: HKObserverQuery?
  @Published var latestHeartRate: HeartRateSample<HKQuantitySample, Double>
  private var personalHeartRateZones: HeartRateZones
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
  
  override init() {
    let hearRate = HeartRateSample<HKQuantitySample, Double>()
    self.latestHeartRate = hearRate
    personalHeartRateZones = HeartRateZones(maxHeartRate: 190, age: 36)
    
    let zone = personalHeartRateZones.getCurrentZone(heartRate: hearRate)
    currentZone = zone
  }
  
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
  
  /// Get specific authorization status by  custom ObjectType
  ///
  /// - Parameter objectType: This is a custom enum of HKObjectType
  /// - Returns: Returns HKAuthorizationStatus
  func checkIsAuthorized(objectType: ObjectType) -> HKAuthorizationStatus {
    return healthStore.authorizationStatus(for: objectType.objectType)
  }
  
  func authorizeHealthKit(completion: @escaping (Bool) -> ()) {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead) { (success, error) in
        if success {
          // Do nothing
          self.isHealthKitAuthorized = true
        } else {
          // Handle authorization failure
          print("HealthKit authorization denied.")
          self.isHealthKitAuthorized = false
        }
        
        completion(true)
      }
      
    } else {
      print("Health data is not supported.")
      self.isHealthKitAuthorized = false
      completion(true)
    }
  }
}

// MARK: FUNCTIONS
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

// MARK: WORKOUT SESSIONS
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
