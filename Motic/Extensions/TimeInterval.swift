//
//  TimeInterval.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/23.
//

import Foundation

extension TimeInterval {
  var formatTimeInterval: String {
    let hours = Int(self / 3600)
    let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(self.truncatingRemainder(dividingBy: 60))

    var formattedTime = ""

    if hours > 0 {
      formattedTime += "\(hours):"
    }
    
    if minutes > 0 || hours > 0 {
      formattedTime += "\(minutes):"
    }
    formattedTime += "\(seconds)"

    return formattedTime
  }
}
