//
//  PreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

import SwiftData

struct PreferenceView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Exercise Preferences") {
                        ExerciseItemView()
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
    func ExerciseItemView() -> some View {
        HStack {
            NavigationLink("Favorites", destination: ExercisePickerView(title: "Favorites", callback: nil))
        }
    }
    
    @ViewBuilder
    func PlanManagementItem() -> some View {
        HStack {
            NavigationLink("Plans", destination: PlanManagementView())
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView().modelContainer(previewContainer.container)
}


