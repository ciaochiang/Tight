//
//  ScheduleExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/21.
//

import SwiftUI
import SwiftData

struct EditScheduledExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var scheduledExercise: ScheduledExercise
    @State private var isExercisePickerViewPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ExerciseView().horizontalSpacing(.leading)
                RepetitionView().horizontalSpacing(.leading)
                SetsView().horizontalSpacing(.leading)
                RestIntervalsView().horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isExercisePickerViewPresented, content: {
                ExercisePickerView(selectedExercise: scheduledExercise.exericse, callback: { exercise in
                    scheduledExercise.exericse = exercise
                    isExercisePickerViewPresented.toggle()
                })
                    .presentationDetents([.large])
            })
        }
    }

    @ViewBuilder
    func ExerciseView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Button(action: {
                /// Display Exercise Picker View
                isExercisePickerViewPresented.toggle()
            }) {
                Text(scheduledExercise.exericse.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            }
        }
    }
    
    @ViewBuilder
    func RepetitionView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repetitions")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", scheduledExercise.repetitions))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Slider(value: $scheduledExercise.repetitions, in: 1...20, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
    
    @ViewBuilder
    func SetsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", scheduledExercise.sets))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Slider(value: $scheduledExercise.sets, in: 1...6, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
    
    @ViewBuilder
    func RestIntervalsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest Intervals")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack(alignment: .center, spacing: 8) {
                Text(scheduledExercise.restIntevals.formatIntervalToMinutesSeconds)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Slider(value: $scheduledExercise.restIntevals, in: 0...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
}

struct ScheduleExerciseView: View {
    /// View Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    var selectedDate: Date
    var incrementalOrderNumber: Int
    @State private var selectedExercise: Exercise = .none
    @State private var repetitions: Double = 10
    @State private var sets: Double = 3
    @State private var restIntervals: TimeInterval = 60
    @State private var isExercisePickerViewPresented: Bool = false
    
    let completion: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ExerciseView().horizontalSpacing(.leading)
                RepetitionView().horizontalSpacing(.leading)
                SetsView().horizontalSpacing(.leading)
                RestIntervalsView().horizontalSpacing(.leading)
                AddButtonView()
            }
            .padding()
            .veriticalSpacing(.bottom)
            .sheet(isPresented: $isExercisePickerViewPresented, content: {
                ExercisePickerView(selectedExercise: selectedExercise, callback: { []exercise in
                    selectedExercise = exercise
                    isExercisePickerViewPresented.toggle()
                })
                    .presentationDetents([.large])
            })
        }
    }
    
    @ViewBuilder
    func ExerciseView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            Button(action: {
                /// Display Exercise Picker View
                isExercisePickerViewPresented.toggle()
            }) {
                Text(selectedExercise.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    func RepetitionView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repetitions")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", repetitions))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $repetitions, in: 1...20, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
    
    @ViewBuilder
    func SetsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(String(format: "%.0f", sets))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $sets, in: 1...6, step: 1.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
    
    @ViewBuilder
    func RestIntervalsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest Intervals")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            HStack(alignment: .center, spacing: 8) {
                Text(formatIntervalToMinutesSeconds(interval: restIntervals))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                
                Slider(value: $restIntervals, in: 0...180, step: 10.0)
                    .accentColor(Color.themeStyle.theme.accent)
            }
        }
    }
    
    @ViewBuilder
    func AddButtonView() -> some View {
        Button(action: {
            /// Save schedule exercise
            let scheduledExercise = ScheduledExercise(exericse: selectedExercise, 
                                                      scheduledDate: selectedDate,
                                                      repetitions: repetitions,
                                                      sets: sets,
                                                      restIntevals: restIntervals,
                                                      isCompleted: false,
                                                      order: incrementalOrderNumber)
            context.insert(scheduledExercise)
            try? context.save()
            completion()
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
        .disabled(selectedExercise == .none)
        .opacity(selectedExercise == .none ? 0.5 : 1)
    }
    
    func formatIntervalToMinutesSeconds(interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let previewContainer = PreviewContainer([ScheduledExercise.self])
    return ScheduleExerciseView(selectedDate: .init(), incrementalOrderNumber: 0, completion: {
        
    })
    .modelContainer(previewContainer.container)
}

struct ExercisePickerView: View {
    @State var selectedExercise: Exercise = .none
    @State private var exercises: [Exercise] = Exercise.allCases
    @State private var upperBodyExercises: [Exercise] = Exercise.upperBodyExercises
    @State private var lowerBodyExercises: [Exercise] = Exercise.lowerBodyExercises
    @State private var coreExercises: [Exercise] = Exercise.coreExercises
    @State private var compoundExercises: [Exercise] = Exercise.compoundExercises
    @State private var favorites: [Exercise] = []
    var preference: UserPreference = UserPreference()
    
    let callback: (Exercise) -> Void
    
    var body: some View {
        NavigationView {
            List {
                // Favorite Section
                FavoriteExercisesView()
                UpperBodyExercisesView()
                LowerBodyExercisesView()
                CoreExercisesView()
                CompoundExercisesView()
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Choose Exercise")
            .onAppear(perform: {
                favorites = preference.retrieveFavoriteExercises()
            })
        }
    }
    
    @ViewBuilder
    func FavoriteExercisesView() -> some View {
        Section("Favorites") {
            ForEach(favorites, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .onTapGesture {
                            selectedExercise = exercise
                            callback(exercise)
                        }
                }
            }
            .onDelete(perform: deleteFavorite)
        }
    }
    
    @ViewBuilder
    func UpperBodyExercisesView() -> some View {
        Section("Upper Body") {
            ForEach(upperBodyExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            selectedExercise = exercise
                            callback(exercise)
                        }
                    Spacer()
                    Image(systemName: favorites.contains(exercise) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(exercise) ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            handleFavoriteAction(exercise: exercise)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func LowerBodyExercisesView() -> some View {
        Section("Lower Body") {
            ForEach(lowerBodyExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            selectedExercise = exercise
                            callback(exercise)
                        }
                    Spacer()
                    Image(systemName: favorites.contains(exercise) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(exercise) ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            handleFavoriteAction(exercise: exercise)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func CoreExercisesView() -> some View {
        Section("Core") {
            ForEach(coreExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            selectedExercise = exercise
                            callback(exercise)
                        }
                    Spacer()
                    Image(systemName: favorites.contains(exercise) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(exercise) ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            handleFavoriteAction(exercise: exercise)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func CompoundExercisesView() -> some View {
        Section("Compoud / Full-Body") {
            ForEach(compoundExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            selectedExercise = exercise
                            callback(exercise)
                        }
                    Spacer()
                    Image(systemName: favorites.contains(exercise) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(exercise) ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            handleFavoriteAction(exercise: exercise)
                        }
                }
            }
        }
    }
    
    func deleteFavorite(indexSet: IndexSet) {
        favorites.remove(atOffsets: indexSet)
        preference.saveFavorite(exercises: favorites)
    }
    
    func handleFavoriteAction(exercise: Exercise) {
        if favorites.contains(exercise) {
            removeFavorite(exercise: exercise)
        } else {
            addFavorite(exercise: exercise)
        }
    }
    
    func addFavorite(exercise: Exercise) {
        // 1. add to list
        favorites.append(exercise)
        
        // 2. Save
        preference.saveFavorite(exercises: favorites)
    }
    
    func removeFavorite(exercise: Exercise) {
        // 1. remove from list
        if let index = favorites.firstIndex(of: exercise) {
            favorites.remove(at: index)
            
            // 2. Save
            preference.saveFavorite(exercises: favorites)
        }
    }
}

