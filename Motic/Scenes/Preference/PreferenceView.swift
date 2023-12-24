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
    @State var isExercisePreferenceViewPresented: Bool = false
    @State var isPlanManagementViewPresented: Bool = false
    
    init(viewModel: PreferenceViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Exercise") {
                        ExerciseItemView()
                        PlanManagementItem()
                    }
                }
                .sheet(isPresented: $isExercisePreferenceViewPresented) {
                    ExercisePickerView { selectedExercise in
                        
                    }
                    .presentationDetents([.large])
                }
                .sheet(isPresented: $isPlanManagementViewPresented) {
                    PlanManagementView()
                        .presentationDetents([.large])
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.themeStyle.theme.background)
            .veriticalSpacing(.top)
            .navigationTitle("Preferences")
        }
    }
    
    @ViewBuilder
    func ExerciseItemView() -> some View {
        Text("Predefined Exercises")
            .horizontalSpacing(.leading)
            .onTapGesture {
                isExercisePreferenceViewPresented.toggle()
            }
    }
    
    @ViewBuilder
    func PlanManagementItem() -> some View {
        Text("Plans")
            .horizontalSpacing(.leading)
            .onTapGesture {
                isPlanManagementViewPresented.toggle()
            }
    }
}

#Preview {
    let viewModel = PreferenceViewModel()
    let previewContainer = PreviewContainer([Plan.self])
    return PreferenceView(viewModel: viewModel).modelContainer(previewContainer.container)
}


