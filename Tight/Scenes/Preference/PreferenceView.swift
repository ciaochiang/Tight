//
//  PreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI
import SwiftData

enum WeightUnit: Int {
    case kilogram = 0
    case pound = 1
    
    var localizationValue: String.LocalizationValue {
        switch self {
        case .kilogram: return "exercise_weight_unit_kilogram"
        case .pound: return "exercise_weight_unit_pound"
        }
    }
    
    var name: String {
        String(localized: localizationValue)
    }
}

struct PreferenceView: View {
    @State private var path = NavigationPath()
    @AppStorage(Constants.DEFAULT_EXERCISE_SETS) var defaultSets: Double = 3
    @AppStorage(Constants.DEFAULT_EXERCISE_REPETITIONS) var defaultRepetitions: Double = 10
    @AppStorage(Constants.DEFAULT_EXERCISE_REST_INTERVALS) var defaultRestIntervals: Double = 90
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) var defaultWeightUnit: Int = 0
    @State private var unitSegementSelection: Int = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    Section(LocalizationProvider.exercise.nameKey) {
                        FavoriteExeriesView()
                        PlanManagementItem()
                    }
                    
                    Section(LocalizationProvider.preferences.nameKey) {
                        WeightUnitItem()
                        RepetitionsSliderItem().padding(.top, 8)
                        SetsSliderItem().padding(.top, 8)
                        RestIntervalSliderItem().padding(.top, 8)
                    }
                }
                .listStyle(DefaultListStyle())
                .scrollContentBackground(.hidden)
            }
            .veriticalSpacing(.top)
            .navigationTitle(LocalizationProvider.settings.nameKey)
            .background(Color.themeStyle.theme.background)
        }
    }
    
    @ViewBuilder
    func FavoriteExeriesView() -> some View {
        HStack {
            NavigationLink(destination: ExercisePickerView(title: LocalizationProvider.favorites.nameKey, isManaging: true, callback: nil)) {
                Text(LocalizationProvider.favorites.nameKey)
                    .font(.subheadline)
                    .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
                    .contentShape(Rectangle())
            }

        }
    }
    
    @ViewBuilder
    func PlanManagementItem() -> some View {
        HStack {
            NavigationLink(destination: PlanManagementView()) {
                Text(LocalizationProvider.plans.nameKey)
                    .font(.subheadline)
                    .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
                    .contentShape(Rectangle())
            }
        }
    }
    
    @ViewBuilder
    func WeightUnitItem() -> some View {
        HStack {
            Text(LocalizationProvider.weightUnit.nameKey)
                .font(.subheadline)
                .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
            Spacer()
            Picker("", selection: $unitSegementSelection) {
                Text(WeightUnit.kilogram.name).tag(0)
                Text(WeightUnit.pound.name).tag(1)
            }
            .frame(maxWidth: 120)
            
            /// Fix the issue that picker will block navigation link works
            .contentShape(Rectangle())
            .pickerStyle(.segmented)
        }
        .onChange(of: unitSegementSelection) { oldValue, newValue in
            defaultWeightUnit = newValue
        }
    }
    
    @ViewBuilder
    func RepetitionsSliderItem() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizationProvider.repetitions.nameKey)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(defaultRepetitions))")
                    .font(.subheadline)
                    .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            }
                .horizontalSpacing(.leading)
            Slider(value: $defaultRepetitions, in: 1...20, step: 1.0)
                .accentColor(Color.themeStyle.theme.accent)
        }
    }
    
    @ViewBuilder
    func SetsSliderItem() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizationProvider.sets.nameKey)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(defaultSets))")
                    .font(.subheadline)
                    .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            }
                .horizontalSpacing(.leading)
            Slider(value: $defaultSets, in: 1...6, step: 1.0)
                .accentColor(Color.themeStyle.theme.accent)
        }
    }
    
    @ViewBuilder
    func RestIntervalSliderItem() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizationProvider.restIntervals.nameKey)
                    .font(.subheadline)
                Spacer()
                Text(defaultRestIntervals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            }
                .horizontalSpacing(.leading)
            Slider(value: $defaultRestIntervals, in: 0...180, step: 10.0)
                .accentColor(Color.themeStyle.theme.accent)
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView().modelContainer(previewContainer.container)
}
