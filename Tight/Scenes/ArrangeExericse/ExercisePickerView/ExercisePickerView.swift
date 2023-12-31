//
//  ExercisePickerView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: LocalizedStringKey
    var isManaging: Bool = false
    @State private var searchText: String = ""

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
        NavigationStack {
            VStack {
                List {
                    // Favorite Section
                    FavoriteExercisesView()

                    
                    if upperBodyExercises.isEmpty == false {
                        UpperBodyExercisesView()
                    }
                    
                    if lowerBodyExercises.isEmpty == false {
                        LowerBodyExercisesView()
                    }
                    
                    if coreExercises.isEmpty == false {
                        CoreExercisesView()
                    }
                    
                    if compoundExercises.isEmpty == false {
                        CompoundExercisesView()
                    }
                }
                .listStyle(DefaultListStyle())
                .scrollContentBackground(.hidden)
                .onAppear(perform: {
                    favorites = preference.retrieveFavoriteExercises()
                })
                .onChange(of: searchText) { oldValue, newValue in
                    // Filter exercises
                    upperBodyExercises = Exercise.upperBodyExercises.filter { newValue.isEmpty || $0.name.lowercased().contains(newValue.lowercased()) }
                    lowerBodyExercises = Exercise.lowerBodyExercises.filter { newValue.isEmpty || $0.name.lowercased().contains(newValue.lowercased()) }
                    coreExercises = Exercise.coreExercises.filter { newValue.isEmpty || $0.name.lowercased().contains(newValue.lowercased()) }
                    compoundExercises = Exercise.compoundExercises.filter { newValue.isEmpty || $0.name.lowercased().contains(newValue.lowercased()) }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(isManaging ? .automatic : .inline)
            .background(Color.themeStyle.theme.background)
            .toolbar {
                if !isManaging {
                    Button(action: {
                        dismiss()
                    }) {
                        Label(LocalizationProvider.close.nameKey, systemImage: "xmark")
                    }
                    .tint(Color.themeStyle.theme.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    func FavoriteExercisesView() -> some View {
        Section(LocalizationProvider.favorites.nameKey) {
            if favorites.isEmpty {
                VStack {
                    Text(LocalizationProvider.noFavorites.nameKey)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                }
            } else {
                ForEach(favorites.filter { searchText.isEmpty || $0.name.contains(searchText) }, id: \.self) { exercise in
                    HStack {
                        Text(exercise.name.capitalized)
                            .fontWeight(selectedExercise == exercise ? .semibold : .none)
                            .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedExercise = exercise
                                callback?(exercise)
                            }
                    }
                }
                .onDelete(perform: deleteFavorite)
            }
        }
    }
    
    @ViewBuilder
    func UpperBodyExercisesView() -> some View {
        Section(LocalizationProvider.upperBody.nameKey) {
            ForEach(upperBodyExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isManaging {
                                handleFavoriteAction(exercise: exercise)
                            } else {
                                selectedExercise = exercise
                                callback?(exercise)
                            }
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
        Section(LocalizationProvider.lowerBody.nameKey) {
            ForEach(lowerBodyExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isManaging {
                                handleFavoriteAction(exercise: exercise)
                            } else {
                                selectedExercise = exercise
                                callback?(exercise)
                            }
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
        Section(LocalizationProvider.core.nameKey) {
            ForEach(coreExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isManaging {
                                handleFavoriteAction(exercise: exercise)
                            } else {
                                selectedExercise = exercise
                                callback?(exercise)
                            }
                        }
                    Spacer()
                    Image(systemName: favorites.contains(exercise) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(exercise) ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func CompoundExercisesView() -> some View {
        Section(LocalizationProvider.compoundOrFullBody.nameKey) {
            ForEach(compoundExercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.name.capitalized)
                        .fontWeight(selectedExercise == exercise ? .semibold : .none)
                        .foregroundColor(selectedExercise == exercise ? .themeStyle.theme.accent : .themeStyle.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isManaging {
                                handleFavoriteAction(exercise: exercise)
                            } else {
                                selectedExercise = exercise
                                callback?(exercise)
                            }
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
    ExercisePickerView(title: LocalizationProvider.favorites.nameKey, isManaging: true, callback: nil)
}
