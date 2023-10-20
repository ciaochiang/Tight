//
//  CustomLogger.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import Foundation
import os

struct CustomLogger {
    private var logger: Logger

    enum SubSystem {
        case `default`
        case watch

        var decription: String {
            switch self {
            case .`default`: return "default"
            case .watch: return "watch"
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

    init(subSystem: SubSystem = .watch, category: Category = .default) {
        self.logger = Logger(subsystem: subSystem.decription, category: category.decription)
    }

    func log(level: OSLogType = .default, message: String) {
        logger.log(level: level, "\(message)")
    }
}
