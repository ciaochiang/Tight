//
//  TrainingSessionDailyReportView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/14.
//

import SwiftUI

struct TrainingSessionDailyReportView: View {
    @Bindable var plan: Plan
    @Binding var isDataChanged: Bool
    @State var duration: TimeInterval = 0
    @State var restIntervals: TimeInterval = 0
    @State var totalVolume: Measurement<UnitMass> = .init(value: 0, unit: .kilograms)
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) var defaultWeightUnit: Int = 0
    @State private var weightUnit: WeightUnit = .kilogram
    
    var body: some View {
        LazyVStack(spacing: 20) {
            HStack {
                MetricWidget(value: duration.formatIntervalToMinutesSeconds, name: LocalizationProvider.duration.nameKey)
                    .padding(.vertical)
                    .horizontalSpacing(.center)
                
                MetricWidget(value: restIntervals.formatIntervalToMinutesSeconds, name: LocalizationProvider.restIntervals.nameKey)
                    .horizontalSpacing(.center)
                
                MetricWidget(value: "\(totalVolume.formmatedWeightValue(weightUnit: weightUnit))", name: LocalizationProvider.volume.nameKey)
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
            weightUnit = WeightUnit(value: defaultWeightUnit)
            
            calculateTimeMetrics(plan: plan)
            calculateVolumeMetric(plan: plan)
        }
        .onChange(of: plan) { oldValue, newValue in
            calculateTimeMetrics(plan: plan)
            calculateVolumeMetric(plan: plan)
        }
        .onChange(of: plan.trainingLog?.endTime) { oldValue, newValue in
            calculateTimeMetrics(plan: plan)
            calculateVolumeMetric(plan: plan)
        }
        .onChange(of: isDataChanged) { oldValue, newValue in
            if newValue {
                calculateVolumeMetric(plan: plan)
                isDataChanged = false
            }
        }
    }
    
    @ViewBuilder
    func MetricWidget(value: String, name: LocalizedStringKey) -> some View {
        VStack {
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
            Text(name)
                .font(.footnote)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
        }
    }
    
    func calculateTimeMetrics(plan: Plan) {
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
    }
    
    func calculateVolumeMetric(plan: Plan) {
        /// Calculate total volume, use kg as base
        var volumes: Measurement<UnitMass> = Measurement(value: 0, unit: UnitMass.kilograms)
        for exercise in plan.arrangedExercises {
            guard exercise.isCompleted else { continue }
            
            /// 0 is kilogram, 1 is pound
            let unit = exercise.weightUnit == 0 ? UnitMass.kilograms : UnitMass.pounds
            let volume = exercise.weight * exercise.sets * exercise.repetitions
            let measurmentValue = Measurement(value: volume, unit: unit)
            volumes = volumes + measurmentValue
        }

        totalVolume = volumes
    }
}

#Preview {
    @State var isDataChanged: Bool = false
    return TrainingSessionDailyReportView(plan: Mocks.mockPlan, isDataChanged: $isDataChanged)
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
