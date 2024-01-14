//
//  TrainingSessionDailyReportView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/14.
//

import SwiftUI

struct TrainingSessionDailyReportView: View {
    @Bindable var plan: Plan
    @State var duration: TimeInterval = 0
    @State var restIntervals: TimeInterval = 0
    @State var totalVolume: Measurement<UnitMass> = .init(value: 0, unit: .kilograms)
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) var defaultWeightUnit: Int = 0
    @State private var weightUnit: WeightUnit = .kilogram
    
    var body: some View {
        LazyVStack(spacing: 20) {
            HStack {
                MetricWidget(value: duration.formatIntervalToMinutesSeconds, name: "Duration")
                    .padding(.vertical)
                    .horizontalSpacing(.center)
                
                MetricWidget(value: restIntervals.formatIntervalToMinutesSeconds, name: "Rest intervals")
                    .horizontalSpacing(.center)
                
                MetricWidget(value: "\(totalVolume.formmatedWeightValue(weightUnit: weightUnit))", name: "Volume")
                    .horizontalSpacing(.center)
            }
            .background(Color.themeStyle.theme.secondaryBackground)
            .cornerRadius(8.0)
            .clipped()
            .compositingGroup()
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.themeStyle.theme.background)
        .horizontalSpacing(.center)
        .onAppear {
            /// Setup prefer weight unit
            if let unit = WeightUnit(rawValue: defaultWeightUnit) {
                weightUnit = unit
            }
            
            calculateMetrics(plan: plan)
        }
        .onChange(of: plan) { oldValue, newValue in
            calculateMetrics(plan: newValue)
        }
        .onChange(of: plan.trainingLog?.endTime) { oldValue, newValue in
            calculateMetrics(plan: plan)
        }
    }
    
    @ViewBuilder
    func MetricWidget(value: String, name: String) -> some View {
        VStack {
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(Color.themeStyle.theme.primary)
            Text(name)
                .font(.footnote)
        }
    }
    
    func calculateMetrics(plan: Plan) {
        /// Setup duration
        if let startTime = plan.trainingLog?.startTime, let endTime = plan.trainingLog?.endTime {
            self.duration = endTime.timeIntervalSince(startTime)
        } else {
            self.duration = 0
        }
        
        /// Setup rest intervals
        if let trainingLog = plan.trainingLog {
            var intervals: [TimeInterval] = []
            for timeFrame in trainingLog.restTimeFrames {
                if let startTime = timeFrame.startTime, let endTime = timeFrame.endTime {
                    let interval = endTime.timeIntervalSince(startTime)
                    intervals.append(interval)
                }
                
            }
            let totalTimeInterval = intervals.reduce(0, +)
            self.restIntervals = totalTimeInterval
        } else {
            self.restIntervals = 0
        }
        
        /// Calculate total volume, use kg as base
        var volumes: [Double] = []
        for exercise in plan.arrangedExercises {
            guard exercise.isCompleted else { continue }
            
            /// 0 is kilogram, 1 is pound
            let weight = exercise.weightUnit == 0 ? exercise.weight : exercise.weight * 0.45359237
            let volume = weight * exercise.sets * exercise.repetitions
            volumes.append(volume)
        }
        
        let totalVolumeKilograms = volumes.reduce(0, +)
        let weightInKilogram = Measurement(value: totalVolumeKilograms, unit: UnitMass.kilograms)
        totalVolume = weightInKilogram
    }
}

#Preview {
    TrainingSessionDailyReportView(plan: Mocks.mockPlan)
}


extension Measurement<UnitMass> {
    func formmatedWeightValue(weightUnit: WeightUnit) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        
        let value = weightUnit == .kilogram ? self : self.converted(to: .pounds)
        return formatter.string(from: value)
    }
}
