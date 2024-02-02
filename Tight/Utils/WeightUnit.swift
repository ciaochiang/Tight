//
//  WeightUnit.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/23.
//

import Foundation

enum WeightUnit: Int {
    case kilogram = 0
    case pound = 1
    
    init(value: Int) {
        switch value {
        case 0: self = .kilogram
        case 1: self = .pound
        default: self = .kilogram
        }
    }
    
    var localizationValue: String.LocalizationValue {
        switch self {
        case .kilogram: return "exercise_weight_unit_kilogram"
        case .pound: return "exercise_weight_unit_pound"
        }
    }
    
    var name: String {
        String(localized: localizationValue)
    }
}
