//
//  HeartRateZones.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import Foundation
import HealthKit

enum ZoneType: Int, CaseIterable {
  case resting = 1
  case fatBuring = 2
  case aerobic = 3
  case anaerobic = 4
  case maximumEffort = 5
  
  func getHeartRateClosedRange(maxHeartRate: Int) -> ClosedRange<Int> {
    // Define heart rate zones as ClosedRanges based on percentages of max heart rate
    switch self {
    case .resting: return 0...Int(0.5 * Double(maxHeartRate)) // 0-50% of max heart rate
    case .fatBuring: return (Int(0.5 * Double(maxHeartRate)) + 1)...Int(0.6 * Double(maxHeartRate)) // 51-60%
    case .aerobic: return (Int(0.6 * Double(maxHeartRate)) + 1)...Int(0.7 * Double(maxHeartRate)) // 61-70%
    case .anaerobic: return (Int(0.7 * Double(maxHeartRate)) + 1)...Int(0.8 * Double(maxHeartRate)) // 71-80%
    case .maximumEffort: return (Int(0.8 * Double(maxHeartRate)) + 1)...maxHeartRate // 81-100%
    }
  }
  
  var aliasName: String {
    return "Zone \(self.rawValue)"
  }
  
  var description: String {
    switch self {
    case .resting: return "Resting"
    case .fatBuring: return "Fat Burning"
    case .aerobic: return "Aerobic"
    case .anaerobic: return "Anaerobic"
    case .maximumEffort: return "Max. Effort"
    }
  }
}

struct Zone: Identifiable {
  let id: String = UUID().uuidString
  let type: ZoneType
  let name: String
  let heartRateRange: ClosedRange<Int>
  var duration: TimeInterval
  
  init(type: ZoneType, heartRateRange: ClosedRange<Int>, duration: TimeInterval) {
    self.type = type
    self.name = type.aliasName
    self.heartRateRange = heartRateRange
    self.duration = duration
  }
}

struct HeartRateZones {
  let maxHeartRate: Int
  let zones: [Zone]
    
  init(maxHeartRate: Int) {
    self.maxHeartRate = maxHeartRate
    
    let allZoneTypes = ZoneType.allCases
    zones = allZoneTypes.map {
      Zone(type: $0, heartRateRange: $0.getHeartRateClosedRange(maxHeartRate: maxHeartRate), duration: .zero)
    }
  }
  
  func getCurrentZone(heartRate: HeartRateSample<HKQuantitySample, Double>) -> Zone? {
    return zones.first(where: { $0.heartRateRange.contains(Int(heartRate.value))})
  }
}
