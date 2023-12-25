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
                                        durationOfSet: 0,
                                        restIntevals: 60,
                                        order: incrementalOrderNumber,
                                        tags: [],
                                        isCompleted: false)
        _arrangedExercise = .init(wrappedValue: exercise)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ExerciseSelectorViewComponent(isPresented: $isPresented, arrangedExericse: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseRepetitionSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseSetsSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseRestIntervalSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
                AddButtonView()
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isPresented, content: {
                ExercisePickerView(title: "Pick Exercise", 
                                   selectedExercise: arrangedExercise.exercise,
                                   callback: { exercise in
                    arrangedExercise.exercise = exercise
                    isPresented.toggle()
                })
                    .presentationDetents([.large])
            })
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
            Text("Add Exercise")
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

struct EditArrangedExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var arrangedExercise: ArrangedExercise
    
    /// View Properties
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ExerciseSelectorViewComponent(isPresented: $isPresented, arrangedExericse: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseRepetitionSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseSetsSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
                ExerciseRestIntervalSliderViewComponent(arrangedExercise: $arrangedExercise).horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isPresented, content: {
                ExercisePickerView(title: "Pick Exercise",
                                   selectedExercise: arrangedExercise.exercise,
                                   callback: { exercise in
                    arrangedExercise.exercise = exercise
                    isPresented.toggle()
                })
                    .presentationDetents([.large])
            })
        }
    }
}


struct ExerciseSelectorViewComponent: View {
    @Binding var isPresented: Bool
    @Binding var arrangedExericse: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            Button(action: {
                /// Display Exercise Picker View
                isPresented.toggle()
            }) {
                Text(arrangedExericse.exercise.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
            }
        }
    }
}

struct ExerciseRepetitionSliderViewComponent: View {
    @Binding var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repetitions")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.repetitions))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.repetitions, in: 1...20, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}

struct ExerciseSetsSliderViewComponent: View {
    @Binding var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", arrangedExercise.sets))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.sets, in: 1...6, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}

struct ExerciseRestIntervalSliderViewComponent: View {
    @Binding var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest Intervals")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(arrangedExercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $arrangedExercise.restIntevals, in: 0...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([ScheduledExercise.self])
    let plan = Plan(name: "Preview", arrangedExercises: [], startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false)
    return CreateArrangedExerciseView(plan: plan, incrementalOrderNumber: 0).modelContainer(previewContainer.container)
}
