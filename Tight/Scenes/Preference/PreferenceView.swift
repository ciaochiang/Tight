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
    
    var nameKey: LocalizedStringKey {
        switch self {
        case .kilogram: return "exercise_weight_unit_kilogram"
        case .pound: return "exercise_weight_unit_pound"
        }
    }
}

struct PreferenceView: View {
    @State private var path = NavigationPath()
    @AppStorage(Constants.DEFAULT_EXERCISE_SETS) var defaultSets: Double = 3
    @AppStorage(Constants.DEFAULT_EXERCISE_REPETITIONS) var defaultRepetitions: Double = 10
    @AppStorage(Constants.DEFAULT_EXERCISE_REST_INTERVALS) var defaultRestIntervals: Double = 90
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) var defaultWeightUnit: Int = 0
    @State private var isWeightUnitDialogPresented: Bool = false
    
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
            .sheet(isPresented: $isWeightUnitDialogPresented) {
                WeightUnitBottomSheetView(isSheetPresented: $isWeightUnitDialogPresented, weightUnit: $defaultWeightUnit)
                    .background(.red)
                    .presentationDetents([.height(180)])
            }
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
    func WeightUnitItem() -> some View {
        HStack {
            Text(LocalizationProvider.weightUnit.nameKey)
                .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
            Spacer()
            Text(WeightUnit(rawValue: defaultWeightUnit)?.nameKey ?? "")
                .font(.caption)
                .foregroundStyle(.gray)
                .frame(height: Constants.DEFAULT_LIST_ROW_HEIGHT)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isWeightUnitDialogPresented.toggle()
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

#Preview("test") {
    WeightUnitBottomSheetView(isSheetPresented: .constant(true), weightUnit: .constant(0))
}


struct WeightUnitBottomSheetView: View {
    @Binding var isSheetPresented: Bool
    @Binding var weightUnit: Int

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button(action: {
                    weightUnit = 0
                    isSheetPresented = false
                }) {
                    HStack {
                        Text(WeightUnit.kilogram.nameKey)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.themeStyle.theme.primary)
                        Spacer()
                        Image(systemName: "checkmark").opacity(weightUnit == 0 ? 1 : 0)
                    }
                }
                .horizontalSpacing(.leading)

                Divider()
                
                Button(action: {
                    weightUnit = 1
                    isSheetPresented = false
                }) {
                    HStack {
                        Text(WeightUnit.pound.nameKey)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.themeStyle.theme.primary)
                        Spacer()
                        Image(systemName: "checkmark").opacity(weightUnit == 1 ? 1 : 0)
                    }
                }
                .horizontalSpacing(.leading)
            }
            .navigationTitle(LocalizationProvider.weightUnit.nameKey)
            .navigationBarTitleDisplayMode(.inline)
            .veriticalSpacing(.bottom)
            .padding()
            .background(Color.themeStyle.theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isSheetPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
        }
    }
}


