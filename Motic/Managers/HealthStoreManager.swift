//
//  HealthStoreManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import HealthKit

class HealthStoreManager: NSObject, ObservableObject {
  private let healthStore = HKHealthStore()
  
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
  
  func authorizeHealthKit(completion: @escaping (Bool) -> ()) {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead) { (success, error) in
        if success {
          // Do nothing
        } else {
          // Handle authorization failure
          print("HealthKit authorization denied.")
        }
        
        completion(true)
      }
      
    } else {
      print("Health data is not supported.")
      completion(true)
    }
  }
}
