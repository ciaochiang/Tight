//
//  Logger.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import Foundation
import os.log

enum LogLevel: Int {
  case debug = 1
  case info = 2
  case warning = 3
  case error = 4
}

struct AppConfiguration {
    static var loggerConfig = LoggerConfiguration()
    // Add other app configurations as needed
}

struct LoggerConfiguration {
  var minLogLevel: LogLevel = .debug
  var logToConsole: Bool = true
  var logToFile: Bool = false
  // Add more configuration options as needed
}

class Logger {
  private let configuration: LoggerConfiguration
  
  init(configuration: LoggerConfiguration) {
    self.configuration = configuration
  }
  
  func log(_ message: String, level: LogLevel) {
    guard level.rawValue >= configuration.minLogLevel.rawValue else { return }
    
    if configuration.logToConsole {
        print("\(level): \(message)")
    }
    
    if configuration.logToFile {
        // Implement file logging here
    }
    
    // Add additional logging destinations or customizations
  }
}
