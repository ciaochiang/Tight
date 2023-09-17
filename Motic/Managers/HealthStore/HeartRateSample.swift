//
//  HeartRateSample.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import HealthKit

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
