//
//  ExercisePickerView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExercisePickerView: View {
    let title: String

    @State var selectedExercise: Exercise = .none
    @State private var exercises: [Exercise] = Exercise.allCases
    @State private var upperBodyExercises: [Exercise] = Exercise.upperBodyExercises
    @State private var lowerBodyExercises: [Exercise] = Exercise.lowerBodyExercises
    @State private var coreExercises: [Exercise] = Exercise.coreExercises
    @State private var compoundExercises: [Exercise] = Exercise.compoundExercises
    @State private var favorites: [Exercise] = []
    var preference: UserPreference = UserPreference()
    
    let callback: ((Exercise) -> Void)?
    
    var body: some View {
        VStack {
            List {
                // Favorite Section
                FavoriteExercisesView()
                UpperBodyExercisesView()
                LowerBodyExercisesView()
                CoreExercisesView()
                CompoundExercisesView()
            }
            .listStyle(DefaultListStyle())
            .scrollContentBackground(.hidden)
            .navigationTitle(title)
            .onAppear(perform: {
                favorites = preference.retrieveFavoriteExercises()
            })
        }
        .background(Color.themeStyle.theme.background)
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
                            callback?(exercise)
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
                            callback?(exercise)
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
                            callback?(exercise)
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
                            callback?(exercise)
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
                            callback?(exercise)
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

#Preview {
    ExercisePickerView(title: "", callback: nil)
}
