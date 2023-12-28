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
                    Section("Exercise Preferences") {
                        FavoriteExeriesView()
                        PlanManagementItem()
                    }
                }
                .listStyle(DefaultListStyle())
                .scrollContentBackground(.hidden)
            }
            .veriticalSpacing(.top)
            .navigationTitle("Settings")
            .background(Color.themeStyle.theme.background)
        }
    }
    
    @ViewBuilder
    func FavoriteExeriesView() -> some View {
        HStack {
            NavigationLink(destination: ExercisePickerView(title: "Favorites", isManaging: true, callback: nil)) {
                Text("Favorites")
            }
        }
    }
    
    @ViewBuilder
    func PlanManagementItem() -> some View {
        HStack {
            NavigationLink(destination: PlanManagementView()) {
                Text("Plans")
            }
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView().modelContainer(previewContainer.container)
}


