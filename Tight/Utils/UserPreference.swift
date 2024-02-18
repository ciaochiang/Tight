//
//  UserPreference.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import Foundation

class UserPreference {
    enum StoreKey: String {
        case selectedSport = "SELECTED_SPORT"
        case favoriteExercises = "FAVORITE_EXERCISES"
    }
    
    func saveFavorite(exercises: [Exercise]) {
        if let encodedData = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.setValue(encodedData, forKey: StoreKey.favoriteExercises.rawValue)
        }
    }
    
    func retrieveFavoriteExercises() -> [Exercise] {
        guard let data = UserDefaults.standard.data(forKey: StoreKey.favoriteExercises.rawValue),
              let decodedItems = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        
        return decodedItems
    }
}
