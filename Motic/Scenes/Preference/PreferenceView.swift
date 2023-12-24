//
//  PreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

import SwiftData

class PreferenceViewModel: ObservableObject {
    @Published var sections: [String] = ["Exercises", "Health Kit"]
}

struct PreferenceView: View {
    @StateObject var viewModel: PreferenceViewModel
    
    init(viewModel: PreferenceViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
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
    let viewModel = PreferenceViewModel()
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView(viewModel: viewModel).modelContainer(previewContainer.container)
}


