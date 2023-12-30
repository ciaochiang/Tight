//
//  LocalizationProvider.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/30.
//

import Foundation
import SwiftUI

enum LocalizationProvider {
    /// Common
    case tags
    
    ///  Exericse Glossary
    case sets
    case repetitions
    case restIntervals
    
    var nameKey: LocalizedStringKey {
        switch self {
        case .tags: return "common_key_tags"
        case .sets: return "Sets"
        case .repetitions: return "Reptitions"
        case .restIntervals: return "Rest Intervals"
        }
    }
}
