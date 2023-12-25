//
//  HeartRate.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/12.
//

import Foundation

struct HeartRate: Identifiable {
    let id: String = UUID().uuidString
    let heartRate: Double
    let timestamp: Date
}
