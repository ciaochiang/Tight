//
//  SportType.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/10.
//

import HealthKit

enum SportType: Int, CaseIterable, Codable, Identifiable {
    case cycling
    case walking
    case traditionalStrengthTraining
    case others
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .cycling
        case 1: self = .walking
        case 2: self = .traditionalStrengthTraining
        default: self = .others
        }
    }
    
    init(activityType: HKWorkoutActivityType) {
        switch activityType {
        case .cycling: self = .cycling
        case .walking: self = .walking
        case .traditionalStrengthTraining:  self = .traditionalStrengthTraining
        default: self = .others
        }
    }
  
    var description: String {
        switch self {
        case .cycling: return "Cycling"
        case .walking: return "Walking"
        case .traditionalStrengthTraining: return "Traditional Strength Training"
        case .others: return "Others"
        }
    }
  
    var systemIconName: String {
        switch self {
        case .cycling: return "figure.indoor.cycle"
        case .walking: return "figure.walk"
        case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
        case .others: return "figure.run.square.stack"
        }
    }
    
    var id: Int {
        return self.hashValue
    }
}
