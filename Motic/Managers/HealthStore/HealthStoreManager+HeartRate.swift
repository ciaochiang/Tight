//
//  HealthStoreManager+HeartRate.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import HealthKit

// MARK: Heart Rate Function
extension HealthStoreManager {
  func stopObserveHeartRateSamples() {
    if let observerQuery = heartRateObserverQuery {
      healthStore.stop(observerQuery)
      dependency.logger.log("Heart rate observer query is stoped.", level: .info)
    }
  }
  
  func startObserveHeartRateSamples() {
    // Stop existing observer
    stopObserveHeartRateSamples()
    
    // Create a new observer
    let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
    heartRateObserverQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
      if let error = error {
        self.dependency.logger.log("\(error.localizedDescription)", level: .error)
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
