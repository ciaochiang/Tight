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
    case exercise
    case settings
    case favorites
    
    /// Actions
    case add
    case addExercise
    
    ///  Exericse Glossary
    case sets
    case repetitions
    case restIntervals
    
    var nameKey: LocalizedStringKey {
        switch self {
            
        /// Common
        case .tags: return "common_key_tags"
        case .exercise: return "common_key_exercise"
        case .settings: return "common_key_settings"
        case .favorites: return "common_key_favorites"
            
        /// Actions
        case .add: return "action_key_add"
        case .addExercise: return "action_key_add_exercise"
            
        /// Exercise Glossary
        case .sets: return "exercise_glossary_sets"
        case .repetitions: return "exercise_glossary_repetitions"
        case .restIntervals: return "exercise_glossary_rest_intervals"
        }
    }
}


extension LocalizedStringKey {
    
    // This will mirror the `LocalizedStringKey` so it can access its
    // internal `key` property. Mirroring is rather expensive, but it
    // should be fine performance-wise, unless you are
    // using it too much or doing something out of the norm.
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
}

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        let language = locale.language.languageCode?.identifier
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}
