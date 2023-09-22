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
    guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
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
  
  
  func getTotalDistanceMeters(workout: HKWorkout) -> Double {
    var distanceMeters: Double = 0
    if let totalDistanceMeters = workout.totalDistance?.doubleValue(for: HKUnit.meter()) {
      distanceMeters = totalDistanceMeters
    } else if let quantity = workout.metadata?["HKIndoorBikeDistance"] as? HKQuantity {
      let totalDistanceMeters = quantity.doubleValue(for: HKUnit.meter())
      distanceMeters = totalDistanceMeters
    }
    
    return distanceMeters
  }
  
  func formattedTotalDistance(meters: Double) -> String {
 
    // Use integer division to get kilometers and modulus operator for remaining meters
    let kilometers = Int(meters / 1000)
    let meters = Int(meters.truncatingRemainder(dividingBy: 1000))

    // Create a formatted string
    var formattedDistance = ""
    if kilometers > 0 {
      formattedDistance = "\(kilometers) km"
    }
    if meters > 0 {
      if !formattedDistance.isEmpty {
          formattedDistance += " "
      }
      formattedDistance += "\(meters) m"
    }
    
    return formattedDistance
  }
  
  func getAvgHeartRateSamples(workout: HKWorkout) {

    // Assume you have fetched workouts into an array called "workouts"

    var averageHeartRatesBySegment: [Double] = []  // This array will store the average heart rates by distance segment
    var accumulatedDistance: Double = 0
    var accumulatedHeartRate: Double = 0
    var segmentDistance: Double = 1000  // 1 kilometer in meters
    
    // Ensure the workout has distance and heart rate data
    // Getting all heart rate samples from workout
    let predicate = HKQuery.predicateForObjects(from: workout)
    guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
          let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling),
          let metadata = workout.metadata else {
      return
    }
    
    print("Metadata: \(metadata)")
    

    
    let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
      if let heartRateSamples = results as? [HKQuantitySample] {
        // Iterate through heart rate samples
        for sample in heartRateSamples {
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            let timestamp = sample.startDate
            // Do something with the heart rate and timestamp
//            print("Heart Rate: \(heartRate), Timestamp: \(timestamp)")
        }
      } else {
        if let error = error {
            print("Error fetching heart rate samples: \(error.localizedDescription)")
        }
      }
    }
    healthStore.execute(heartRateQuery)
    
    
    let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .distanceCycling)!]
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
      if success {
        let distanceQuery = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
          if let distanceSamples = results as? [HKQuantitySample] {
            // Iterate through heart rate samples
            for sample in distanceSamples {
                let distance = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let timestamp = sample.startDate
                // Do something with the heart rate and timestamp
//                print("Distance: \(distance), Timestamp: \(timestamp)")
            }
          } else {
            if let error = error {
                print("Error fetching distance samples: \(error.localizedDescription)")
            }
          }
        }
        
        self.healthStore.execute(distanceQuery)
      }
    }
    
//
//    // Iterate through distance samples and calculate average heart rate per kilometer
//    for i in 0..<distanceSamples.count {
//        let distanceSample = distanceSamples[i]
//        let heartRateSample = heartRateSamples[i]
//
//        // Convert distance sample to meters
//      let distanceInMeters = distanceSample.quantity.doubleValue(for: HKUnit(
//
//        // Check if we've crossed a kilometer boundary
//        if distanceInMeters >= accumulatedDistance + segmentDistance {
//            if accumulatedDistance > 0 {
//                // Calculate average heart rate for the segment and append to the array
//                let averageHeartRate = accumulatedHeartRate / (accumulatedDistance / segmentDistance)
//                averageHeartRatesBySegment.append(averageHeartRate)
//            }
//
//            // Reset accumulated values for the next segment
//            accumulatedDistance = distanceInMeters
//            accumulatedHeartRate = 0
//        }
//
//        // Accumulate heart rate values
//        accumulatedHeartRate += heartRateSample.quantity.doubleValue(for: .beatsPerMinute())
//    }
//
//    // Calculate the average heart rate for the last segment if there's any data
//    if accumulatedDistance > 0 {
//        let averageHeartRate = accumulatedHeartRate / (accumulatedDistance / segmentDistance)
//        averageHeartRatesBySegment.append(averageHeartRate)
//    }
//
//    // Now, "averageHeartRatesBySegment" contains the average heart rates for each kilometer segment

  }
}
