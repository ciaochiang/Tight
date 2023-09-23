//
//  HealthStoreManager+HeartRate.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import HealthKit

// MARK: Heart Rate Function
extension HealthStoreManager {
  func startObserveHeartRateSamples() {
    guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
    
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
      
      if let heartRateQuantitySample = results?.first as? HKQuantitySample {
        let heartRateSample = HeartRateSample<HKQuantitySample, Double>(sample: heartRateQuantitySample)
        self.latestHeartRate = heartRateSample
      }
    }
    
    healthStore.execute(query)
  }
  
  func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
    guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
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
  
  func getAvgHeartRate(from workout: HKWorkout, _completion: @escaping (Double, Error?) -> ()) {
    guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
    let readTypes: Set<HKObjectType> = [heartRateType]
    let predicate = HKQuery.predicateForObjects(from: workout)
    
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
      if success {
        let query = HKStatisticsQuery(quantityType: heartRateType,
                                      quantitySamplePredicate: predicate,
                                      options: .discreteAverage) { (query, result, error) in
          if let result = result, let averageHeartRate = result.averageQuantity() {
            // The averageHeartRate variable now contains the average heart rate value
            let beatsPerMinute = averageHeartRate.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            self.dependency.logger.log("Average Heart Rate: \(beatsPerMinute) bpm", level: .info)
            _completion(beatsPerMinute, nil)
          } else {
            if let error = error {
              self.dependency.logger.log("Error calculating average heart rate: \(error.localizedDescription)", level: .error)
              _completion(0, error)
            }
          }
        }
        
        self.healthStore.execute(query)
      }
    }
  }
  
  func getAllHeartRateSamples(workout: HKWorkout, _completion: @escaping ([ChartData<Double>]) -> ()) {
    guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
    let predicate = HKQuery.predicateForObjects(from: workout)
    
    var hearRates: [ChartData<Double>] = []
    let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                       predicate: predicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) { (query, results, error) in
      if let heartRateSamples = results as? [HKQuantitySample] {
        // Iterate through heart rate samples
        for sample in heartRateSamples {
          let heartRateValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
          let heartRate = ChartData<Double>(startDate: sample.startDate,
                                            endDate: sample.endDate,
                                            value: heartRateValue)
          hearRates.append(heartRate)
        }
        _completion(hearRates)
      } else {
        if let error = error {
            print("Error fetching heart rate samples: \(error.localizedDescription)")
        }
        _completion(hearRates)
      }
    }
    healthStore.execute(heartRateQuery)
  }
  
  func getHeartRateZoneDurations(from heartRates: [ChartData<Double>], zones: [Zone]) -> [ZoneType: TimeInterval] {
    var zoneDurations: [ZoneType: TimeInterval] = [:]

    var previousSample: ChartData<Double>? = nil
    for sample in heartRates {
      if let previusStartDate = previousSample?.startDate {
        let heartRate = Int(sample.value)
                
        if let zone = zones.first(where: { $0.heartRateRange.contains(heartRate) }) {
          let duration = sample.startDate.timeIntervalSince(previusStartDate)
          zoneDurations[zone.type, default: 0.0] += duration
        }
      }

      previousSample = sample
    }
    
    dependency.logger.log("Zone Durations: \(zoneDurations)", level: .info)
    return  zoneDurations
  }
}
