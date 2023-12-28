//
//  UserPreference.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import Foundation

class UserPreference {
    private let SELECTED_SPORT_KEY: String = "SELECTED_SPORT"
    private let FAVORITE_SPORTS_KEY: String = "FAVORIATE_SPORTS"
    private let FAVORITE_EXERCISES_KEY: String = "FAVORITE_EXERCISES"
    
    func saveFavorite(exercises: [Exercise]) {
        if let encodedData = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.setValue(encodedData, forKey: FAVORITE_EXERCISES_KEY)
        }
    }
    
    func retrieveFavoriteExercises() -> [Exercise] {
        guard let data = UserDefaults.standard.data(forKey: FAVORITE_EXERCISES_KEY),
              let decodedItems = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        
        return decodedItems
    }
}
