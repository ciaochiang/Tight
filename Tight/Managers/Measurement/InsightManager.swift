//
//  InsightManager.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/5.
//

import Foundation
import SwiftUI
import SwiftData

typealias InsightDataSet = [Exercise: [InsightData]]
class InsightManager: ObservableObject {
    @Environment(\.modelContext) private var context
    @Published var dataSet: InsightDataSet = [:]
    
    func load(from: Date, to: Date) {
        /// Load  plans
//        let plans = PersistentStoreManager.shared.fetchPlans(context: context, startDate: from, endDate: to)
                
        /// Aggregate data
//        for exercise in Exercise.allCases {
//            let aggregatedData = aggregateData(by: exercise, plans: plans)
//            DispatchQueue.main.async {
//                self.dataSet[exercise] = aggregatedData
//            }
//        }
    }
    
    func aggregateData(by exercise: Exercise, plans: [Plan]) -> [InsightData] {
        return []
    }
}

struct InsightData: Identifiable {
    var id = UUID()
    var day: Date
    var weight: Double
}

