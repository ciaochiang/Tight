//
//  Measurement+Extension.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/18.
//

import Foundation

extension Measurement<UnitMass> {
    func formmatedWeightValue(weightUnit: WeightUnit) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        
        let value = weightUnit == .kilogram ? self : self.converted(to: .pounds)
        return formatter.string(from: value)
    }
}
