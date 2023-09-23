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
    
    if hours > 0 {
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%02d:%02d", minutes, seconds)
    }
  }
}
