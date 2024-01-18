//
//  EditArrangedExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct EditArrangedExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var arrangedExercise: ArrangedExercise
    @State private var isPresented: Bool = false
    @Binding var isDataChanged: Bool
    var isPlanMode: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            ExerciseSelectorViewComponent(isPresented: $isPresented, arrangedExericse: arrangedExercise)
                            ExerciseWeightViewComponent(arrangedExercise: arrangedExercise)
                        }.horizontalSpacing(.leading)
                        
                        Divider()
                        
                        ExerciseRepetitionSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                        ExerciseSetsSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                        ExerciseRestIntervalSliderViewComponent(arrangedExercise: arrangedExercise).horizontalSpacing(.leading)
                        ExerciseTagPickerViewComponent(arrangedExercise: arrangedExercise)
                            .horizontalSpacing(.leading)
                    }
                }
                .padding()

                if !isPlanMode {
                    Spacer()
                    VStack {
                        Button(action: {
                            arrangedExercise.isCompleted.toggle()
                            dismiss()
                        }) {
                            Label(LocalizationProvider.complete.nameKey, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color.themeStyle.theme.white)
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                                .contentShape(Rectangle())
                                .padding(.vertical)
                        }
                    }
                    .background(arrangedExercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.themeStyle.theme.black.opacity(0.4))
                }
            }
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
            .navigationTitle(arrangedExercise.exercise.name)
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
            .onChange(of: arrangedExercise.weight) { oldValue, newValue in
                if oldValue != newValue {
                    isDataChanged.toggle()
                }
            }
            .onChange(of: arrangedExercise.repetitions) { oldValue, newValue in
                if oldValue != newValue {
                    isDataChanged.toggle()
                }
            }
            .onChange(of: arrangedExercise.sets) { oldValue, newValue in
                if oldValue != newValue {
                    isDataChanged.toggle()
                }
            }
        }
    }
}


#Preview {
    @State var isDataChanged: Bool = false
    let previewContainer = PreviewContainer([ArrangedExercise.self])
    return EditArrangedExerciseView(arrangedExercise: Mocks.mockArrangedExercise, isDataChanged: $isDataChanged).modelContainer(previewContainer.container)
}
