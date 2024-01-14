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
    
    var shorterFormatInterval: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
          return String(format: "%dh %02dm", hours, minutes)
        } else {
          return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formatAvgSpeedTimeInterval: String {
//        let hours = Int(self / 3600)
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        if minutes > 0 {
          return String(format: "%d'%02d\"", minutes, seconds)
        } else {
          return String(format: "%02d\"", seconds)
        }
    }
    
    var formatIntervalToMinutesSeconds: String {
        let hours = Int(self / 3600)
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
