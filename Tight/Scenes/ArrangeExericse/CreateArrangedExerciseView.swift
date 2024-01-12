//
//  CreateArrangedExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/21.
//

import SwiftUI
import SwiftData

struct CreateArrangedExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage(Constants.DEFAULT_EXERCISE_REST_INTERVALS) private var defaultRestIntervals: Double = 90
    @AppStorage(Constants.DEFAULT_EXERCISE_SETS) private var defaultSets: Double = 3
    @AppStorage(Constants.DEFAULT_EXERCISE_REPETITIONS) private var defaultRepetitions: Double = 10
    @AppStorage(Constants.DEFAULT_EXERCISE_WEIGHT_UNIT) private var defaultWeightUnit: Int = 0
    
    @Bindable var plan: Plan
    @State private var arrangedExercise: ArrangedExercise
    private var incrementalOrderNumber: Int
    
    /// View Properties
    @State private var isPresented: Bool = false
    
    let completion: ((ArrangedExercise) -> Void)?
    
    init(plan: Plan, incrementalOrderNumber: Int, completion: ((ArrangedExercise) -> Void)? = nil) {
        self.plan = plan
        self.incrementalOrderNumber = incrementalOrderNumber
        self.completion = completion
        let exercise = ArrangedExercise(exercise: .none,
                                        repetitions: 10,
                                        sets: 3,
                                        weight: 0,
                                        weightUnit: 0,
                                        durationOfSet: 0,
                                        restIntevals: 60,
                                        order: incrementalOrderNumber,
                                        tags: [],
                                        isCompleted: false)
        _arrangedExercise = .init(wrappedValue: exercise)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    ExerciseSelectorViewComponent(isPresented: $isPresented, arrangedExericse: arrangedExercise)
                    ExerciseWeightViewComponent(arrangedExercise: arrangedExercise)
                }.horizontalSpacing(.leading)
                
                Divider()

                ExerciseRepetitionSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                ExerciseSetsSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                ExerciseRestIntervalSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                AddButtonView()
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isPresented, content: {
                ExercisePickerView(title: LocalizationProvider.pickExercise.nameKey,
                                   selectedExercise: arrangedExercise.exercise,
                                   callback: { exercise in
                    arrangedExercise.exercise = exercise
                    isPresented.toggle()
                })
                    .presentationDetents([.large])
            })
            .navigationTitle(LocalizationProvider.addExercise.nameKey)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label(LocalizationProvider.close.nameKey, systemImage: "xmark")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
            .onAppear {
                arrangedExercise.weightUnit = defaultWeightUnit
                arrangedExercise.restIntevals = defaultRestIntervals
                arrangedExercise.sets = defaultSets
                arrangedExercise.repetitions = defaultRepetitions
            }
        }
    }
    
    @ViewBuilder
    func AddButtonView() -> some View {
        Button(action: {
            /// Save arranged exercise
            plan.arrangedExercises.append(arrangedExercise)
            completion?(arrangedExercise)
            dismiss()
        }) {
            Text(LocalizationProvider.add.nameKey)
                .font(.title3)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .horizontalSpacing(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .background(Color.themeStyle.theme.accent, in: .rect(cornerRadius: 10))
        }
        .disabled(arrangedExercise.exercise == .none)
        .opacity(arrangedExercise.exercise == .none ? 0.5 : 1)
    }
}

#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    let plan = Plan(name: "Preview", startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
    return CreateArrangedExerciseView(plan: plan, incrementalOrderNumber: 0).modelContainer(previewContainer.container)
}
