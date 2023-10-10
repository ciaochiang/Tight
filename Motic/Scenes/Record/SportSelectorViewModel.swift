//
//  SportSelectorViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/10.
//

import Foundation
import SwiftUI

protocol SportSelectorViewModelDependency {
    var logger: Logger { get }
}

class SportSelectorViewModelDependencyImp: SportSelectorViewModelDependency {
    var logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
}

//struct SportSelectorItem: Identifiable, Codable, Equatable, Hashable {
//    var id = UUID()
//    var type: SportType
//    var isFavorite: Bool = false
//
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        return lhs.type == rhs.type
//    }
//}

class SportSelectorViewModel: ObservableObject {
    var dependency: SportSelectorViewModelDependency
    @Published var favorites: [SportType] = []
    @Published var sports: [SportType] = []
    @Published var selectedSport: SportType = .cycling
    var preference: UserPreference = UserPreference()
    
    init(dependency: SportSelectorViewModelDependency) {
        self.dependency = dependency
        
        // Retrieve all sports
        sports = SportType.allCases

        // Retrieve favorite sports
        favorites = retrieveFavoriteSports()

        // Retrieve previous selected sport
        selectedSport = retrieveSelectedSport()
    }
    
    func addFavorite(sport: SportType) {
        // 1. add to list
        favorites.append(sport)
        
        // 2. Save
        preference.saveFavorite(sports: favorites)
    }
    
    func removeFavorite(sport: SportType) {
        // 1. remove from list
        if let index = favorites.firstIndex(of: sport) {
            favorites.remove(at: index)
            
            // 2. Save
            preference.saveFavorite(sports: favorites)
        }
    }
    
    func retrieveFavoriteSports() -> [SportType] {
        return preference.retrieveFavoriteSports()
    }
    
    func selectSport(sport: SportType) {
        selectedSport = sport
        
        // save
        preference.saveSelectedSport(sport: selectedSport)
    }
    
    func retrieveSelectedSport() -> SportType {
        return preference.retrieveSelectedSport()
    }
    
    func handleFavoriteAction(sport: SportType) {
        if favorites.contains(sport) {
            removeFavorite(sport: sport)
        } else {
            addFavorite(sport: sport)
        }
    }
}

class UserPreference {
    private let SELECTED_SPORT_KEY: String = "SELECTED_SPORT"
    private let FAVORITE_SPORTS_KEY: String = "FAVORIATE_SPORTS"
    
    func saveSelectedSport(sport: SportType) {
        // save
        if let encodedData = try? JSONEncoder().encode(sport) {
            UserDefaults.standard.setValue(encodedData, forKey: SELECTED_SPORT_KEY)
        }
    }

    
    func retrieveSelectedSport() -> SportType {
        guard let data = UserDefaults.standard.data(forKey: SELECTED_SPORT_KEY),
              let decodedItem = try? JSONDecoder().decode(SportType.self, from: data) else {
            
            // Return defaul value
            return .walking
        }
        
        return decodedItem
    }
    
    func saveFavorite(sports: [SportType]) {
        if let encodedData = try? JSONEncoder().encode(sports) {
            UserDefaults.standard.setValue(encodedData, forKey: FAVORITE_SPORTS_KEY)
        }
    }
        
    func retrieveFavoriteSports() -> [SportType] {
        guard let data = UserDefaults.standard.data(forKey: FAVORITE_SPORTS_KEY),
              let decodedItems = try? JSONDecoder().decode([SportType].self, from: data) else {
            return []
        }
        
        return decodedItems
    }
}

