//
//  SportProvider.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/19.
//

import SwiftUI

struct Sport: Codable, Hashable {
    var id: Int
    var description: String
}

class SportProvider {
    let CACHE_ALL_SPORTS_KEY = "CACHE_ALL_SPORTS"
    var connectivity: WatchConnectivityProvider
    
    init(connectivity: WatchConnectivityProvider) {
        self.connectivity = connectivity
    }
    
    func fetchAllSports(completion: @escaping ([Sport]) -> ()) {
        // Try retrieve from user defaults when user hasn't connected to iphone
        if let data = UserDefaults.standard.data(forKey: CACHE_ALL_SPORTS_KEY),
            let decodedData = try? JSONDecoder().decode([Sport].self, from: data) {
            completion(decodedData)
        }
        
        // Fetch all sports from iphone
        fetchAllSportsFromiPhone { [weak self] sports in
            completion(sports)
            self?.storeToUserDefaults(sports: sports)
        }
    }
    
    private func fetchAllSportsFromiPhone(completion: @escaping ([Sport]) -> Void) {
        connectivity.send(message: ["request": "fetchSports"]) { response in
            if let values = response["reply"] as? [[String: Any]] {
                let allSports = values.map { Sport(id: $0["id"] as? Int ?? 0, description: $0["description"] as? String ?? "") }
                completion(allSports)
            } else {
                completion([])
            }
        }
    }
    
    private func storeToUserDefaults(sports: [Sport]) {
        guard sports.count > 0,
              let encodedData = try? JSONEncoder().encode(sports) else { return }
        
        UserDefaults.standard.set(encodedData, forKey: CACHE_ALL_SPORTS_KEY)
    }
}
