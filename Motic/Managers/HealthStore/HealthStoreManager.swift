//
//  HealthStoreManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import HealthKit
import SwiftUI

protocol HealthStoreManagerDependency {
  var logger: CustomLogger { get }
}

class HealthStoreManagerDependencyImp: HealthStoreManagerDependency {
  var logger: CustomLogger
  
  init(logger: CustomLogger) {
    self.logger = logger
  }
}

enum SportType: Int, CaseIterable, Codable, Identifiable {
    case cycling
    case walking
    case traditionalStrengthTraining
    case others
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .cycling
        case 1: self = .walking
        case 2: self = .traditionalStrengthTraining
        default: self = .others
        }
    }
    
    init(activityType: HKWorkoutActivityType) {
        switch activityType {
        case .cycling: self = .cycling
        case .walking: self = .walking
        case .traditionalStrengthTraining:  self = .traditionalStrengthTraining
        default: self = .others
        }
    }
  
    var description: String {
        switch self {
        case .cycling: return "Cycling"
        case .walking: return "Walking"
        case .traditionalStrengthTraining: return "Traditional Strength Training"
        case .others: return "Others"
        }
    }
  
    var systemIconName: String {
        switch self {
        case .cycling: return "figure.indoor.cycle"
        case .walking: return "figure.walk"
        case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
        case .others: return "figure.run.square.stack"
        }
    }
    
    var id: Int {
        return self.hashValue
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
  @Published var dateOfBirth: DateComponents?
  @Published var currentZone: Zone?
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
    personalHeartRateZones = HeartRateZones(maxHeartRate: 192)
    
    let zone = personalHeartRateZones.getCurrentZone(heartRate: hearRate)
    currentZone = zone
    
    super.init()
    
    self.retrieveDateOfBirth()
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

// MARK: Biological Characteristic
extension HealthStoreManager {
  func retrieveDateOfBirth() {
    if let dateOfBirthComponent = try? healthStore.dateOfBirthComponents() {
      dateOfBirth = dateOfBirthComponent
      
      let year = dateOfBirthComponent.year ?? 0
      let month = dateOfBirthComponent.month ?? 0
      let day = dateOfBirthComponent.day ?? 0
      dependency.logger.log("Date of birth: \(year)/\(month)/\(day)", level: .info)
    } else {
      dependency.logger.log("Date of birth is not available.", level: .info)
    }
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
