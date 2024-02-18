//
//  TTLogger.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import Foundation
import os

class TTLogger: ObservableObject {
    var logger: Logger
    
    enum SubSystem {
        case `default`
        case dev
        
        var decription: String {
            switch self {
            case .`default`: return "default"
            case .dev: return "dev"
            }
        }
    }
    
    enum Category {
        case `default`
        
        var decription: String {
            switch self {
            case .`default`: return "default"
            }
        }
    }
    
    init(subSystem: SubSystem = .default, category: Category = .default) {
        self.logger = Logger(subsystem: subSystem.decription, category: category.decription)
    }
    
    func log(_ message: String, level: OSLogType = .default) {
        logger.log(level: level, "\(message)")
    }
}
