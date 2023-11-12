//
//  Distance.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/12.
//

import Foundation

struct Distance: Identifiable {
    let id: String = UUID().uuidString
    let distanceInMeter: Double
    let timestamp: Date
}
