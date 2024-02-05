//
//  InsightHomeView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/5.
//

import SwiftUI
import SwiftData
import Charts

struct InsightHomeView: View {
    @Environment(\.modelContext) var context
    @State var plans: [Plan] = []
    @State var recordedExercises: [Exercise] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(recordedExercises, id: \.self) { exercise in
                        InsightChartCardView(execicse: exercise, plans: plans)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .navigationTitle(LocalizationProvider.insight.nameKey)
            .onAppear {
                /// Get this month start date and end date
                let today = Date.now
                let startDate = today.startOfMonth
                let endDate = today.endOfMonth
                                
                /// Load insight
                DispatchQueue.global().async {
                    let dedupExercises = loadDedupExercises(from: startDate, to: endDate)
                    DispatchQueue.main.async {
                        self.recordedExercises = dedupExercises
                    }
                }
            }
        }
    }
    
    func loadDedupExercises(from: Date, to: Date) -> [Exercise] {
        let plans = PersistentStoreManager.shared.fetchPlans(context: self.context, startDate: from, endDate: to)
        self.plans = plans
        
        /// Retrieve recorded exercises and do deduplication
        let flattedExercises = plans.compactMap { plan in
            return plan.arrangedExercises?.map { exercise in
                return exercise.exercise
            }
        }.flatMap { $0 }
        
        let dedupExercises = Set(flattedExercises)
        
        return Array(dedupExercises).sorted { e1, e2 in
            return e1.name < e2.name
        }
    }
}


#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    let context = ModelContext(previewContainer.container)
    return InsightHomeView()
        .modelContext(context)
}
