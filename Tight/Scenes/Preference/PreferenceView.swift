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
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    Section(LocalizationProvider.exercise.nameKey) {
                        FavoriteExeriesView()
                        PlanManagementItem()
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
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView().modelContainer(previewContainer.container)
}


