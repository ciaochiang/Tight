//
//  Mocks.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/22.
//

import Foundation
import HealthKit
import CoreLocation

class Mocks {
    static var logger: CustomLogger {
        return CustomLogger(subSystem: .dev)
    }
}

extension Mocks {
    static var experimentProvider: ExperiementsProvider {
        return ExperiementsProvider()
    }
}
