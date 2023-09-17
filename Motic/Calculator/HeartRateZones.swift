//
//  HeartRateZones.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import Foundation
import HealthKit

struct Zone {
  let zoneName: String
  let heartRateRange: ClosedRange<Int>
  
  init(zoneName: String, heartRateRange: ClosedRange<Int>) {
    self.zoneName = zoneName
    self.heartRateRange = heartRateRange
  }
}

struct HeartRateZones {
  let maxHeartRate: Int
  let age: Int
  let zones: [Zone]
    
  init(maxHeartRate: Int, age: Int) {
    self.maxHeartRate = maxHeartRate
    self.age = age
    
    let heartRateReserve = maxHeartRate - 60  // Using 60 as a resting heart rate
    let lowerBound = 0.6
    let upperBounds: [Double] = [0.7, 0.8, 0.9, 1.0]
        
    var list: [Zone] = []
        
    for (index, upperBound) in upperBounds.enumerated() {
      let lower = Int(Double(heartRateReserve) * lowerBound)
      let upper = Int(Double(heartRateReserve) * upperBound)
      let zone = Zone(zoneName: "Zone \(index + 1)", heartRateRange: lower...(upper + 60))
      list.append(zone)
    }
    self.zones = list
  }
  
  func getCurrentZone(heartRate: HeartRateSample<HKQuantitySample, Double>) -> Zone? {
    return zones.first(where: { $0.heartRateRange.contains(Int(heartRate.value))})
  }
}
