//
//  BaseSample.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import Foundation

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
