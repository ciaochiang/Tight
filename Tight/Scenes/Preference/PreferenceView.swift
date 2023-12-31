//
//  PreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI
import SwiftData

struct PreferenceView: View {
    @State private var path = NavigationPath()
    @AppStorage(Constants.DEFAULT_EXERCISE_SETS) var defaultSets: Double = 3
    @AppStorage(Constants.DEFAULT_EXERCISE_REPETITIONS) var defaultRepetitions: Double = 10
    @AppStorage(Constants.DEFAULT_EXERCISE_REST_INTERVALS) var defaultRestIntervals: Double = 90
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    Section(LocalizationProvider.exercise.nameKey) {
                        FavoriteExeriesView()
                        PlanManagementItem()
                    }
                    
                    Section(LocalizationProvider.preferences.nameKey) {
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
                    .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
                    .contentShape(Rectangle())
            }
        }
    }
    
    @ViewBuilder
    func RepetitionsSliderItem() -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(LocalizationProvider.repetitions.nameKey)
                Spacer()
                Text("\(Int(defaultRepetitions))")
                    .font(.caption)
                    .foregroundStyle(.gray)
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
                Spacer()
                Text("\(Int(defaultSets))")
                    .font(.caption)
                    .foregroundStyle(.gray)
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
                Spacer()
                Text(defaultRestIntervals.formatIntervalToMinutesSeconds)
                    .font(.caption)
                    .foregroundStyle(.gray)
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


