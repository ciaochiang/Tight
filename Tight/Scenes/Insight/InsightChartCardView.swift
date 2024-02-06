//
//  InsightChartCardView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/5.
//

import SwiftUI
import Charts

struct InsightChartCardView: View {
    private var plans: [Plan] = []
    private var exercise: Exercise = .none
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) private var defaultWeightUnit: Int = 0
    @State var dataSet: [InsightData] = []
    
    init(execicse: Exercise = .benchPress, plans: [Plan] = []) {
        self.exercise = execicse
        self.plans = plans
    }
    
    var body: some View {
        LazyVStack {
            LazyVStack {
                VStack {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                        .padding()
                }
                .horizontalSpacing(.leading)
 
                Chart(dataSet) {
                    LineMark(
                        x: .value("Day", $0.day, unit: .day),
                        y: .value("Weight", $0.weight)
                    )
                    .lineStyle(.init(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.linear)
                    .accessibilityLabel(exercise.name)
                    .accessibilityValue("\($0.weight) \(WeightUnit(value: defaultWeightUnit).name)")
                    .symbol {
                        Circle()
                            .fill(Color.themeStyle.theme.accent)
                            .frame(width: 10)
                    }
                    
                    AreaMark(
                        x: .value("Day", $0.day, unit: .day),
                        yStart: .value("WeightLow", 0),
                        yEnd: .value("WeightLow",  $0.weight)
                    )
                    .foregroundStyle(gradientColor)
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .trailing)
                }
                .chartPlotStyle{plotArea in
                    plotArea.frame(maxWidth: .infinity, minHeight: 60, maxHeight: 80)
                }
                .foregroundStyle(Color.themeStyle.theme.accent)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.themeStyle.theme.secondaryBackground)
        .compositingGroup()
        .cornerRadius(16.0)
        .onAppear {
            DispatchQueue.global().async {
                let processedDataSet = self.processData(exercise: exercise, plans: plans)
                DispatchQueue.main.async {
                    withAnimation {
                        self.dataSet = processedDataSet
                    }
                }
            }
        }
    }
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.themeStyle.theme.accent.opacity(0.8),
                    Color.themeStyle.theme.accent.opacity(0.01),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    func processData(exercise: Exercise, plans: [Plan]) -> [InsightData] {
        let sortedPlans = plans.sorted(by: { $0.startDate < $1.startDate })
        var dataSet: [InsightData] = []
        for plan in sortedPlans {
            let day = plan.startDate
            guard let exercises = plan.arrangedExercises?.filter({ $0.exercise == exercise && $0.isCompleted }),
                let maxValueExercise = exercises.max(by: { $0.weight < $1.weight }) else  {
                continue
            }
            
            let weightUnit = maxValueExercise.weightUnit
            
            ///  Convert value to prefer weight unit
            let measurement: Measurement<UnitMass> = .init(value: maxValueExercise.weight, unit: weightUnit == 0 ? .kilograms : .pounds)
            let convertedValue = measurement.converted(to: defaultWeightUnit == 0 ? .kilograms : .pounds).value
            let data: InsightData = .init(day: day, weight: convertedValue)
            dataSet.append(data)
        }
        
        return dataSet
    }
}

#Preview {
    InsightChartCardView()
}
