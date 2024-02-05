//
//  PersistentStoreManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/5.
//

import Foundation
import SwiftUI
import SwiftData

class PersistentStoreManager {
    static let shared = PersistentStoreManager()
    @EnvironmentObject private var logger: CustomLogger
    
    func fetchPlans(context: ModelContext, startDate: Date, endDate: Date) -> [Plan] {
        let fetchDescriptor = FetchDescriptor<Plan>(predicate: #Predicate<Plan> {
            $0.startDate >= startDate && $0.startDate <= endDate && $0.isPreset == false
        }, sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        
        do {
            return try context.fetch(fetchDescriptor)
        }
        catch {
            logger.log(error.localizedDescription, level: .error)
            return []
        }
    }
}
