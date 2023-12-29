//
//  Tag.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/27.
//

import SwiftUI
import SwiftData



enum ExericiseTag: Int, CaseIterable {
    case others = 0
    
    /// Ground Hardware
    case bench = 1
    case rack = 2
    case machine = 3
    case pullupBar = 4
    case treadmill = 5
    case rower = 6
    
    ///  Hand Handware
    case dumbbell = 100
    case barbell = 101
    case resistanceBand = 102
    case kettlebell = 103
    case medicineBall = 104
    case tricepRope = 105
    case battleRope = 106
    case trx = 107
    
    var name: String {
        switch self {
        case .others: return "Others"
            
        case .bench: return "Bench"
        case .rack: return "Rack"
        case .machine: return "Machine"
        case .pullupBar: return "Pull up Bar"
        case .treadmill: return "Treadmill"
        case .rower: return "Rower"
            
        case .dumbbell: return "Dumbbell"
        case .barbell: return "Barbell"
        case .resistanceBand: return "Resistance Band"
        case .kettlebell: return "Kettelbell"
        case .medicineBall: return "Medicine Ball"
            
        case .tricepRope: return "Tricep Rope"
        case .battleRope: return "Battle Rope"
        case .trx: return "TRX"
        }
    }
}
