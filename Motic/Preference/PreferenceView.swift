//
//  PreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

class PreferenceViewModel: ObservableObject {
    @Published var sections: [String] = ["Exercises", "Health Kit"]
}

struct PreferenceView: View {
    @StateObject var viewModel: PreferenceViewModel
    @State var isExercisePreferenceViewPresented: Bool = false
    
    init(viewModel: PreferenceViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 16) {
                    ForEach(viewModel.sections, id: \.self) { section in
                        HStack {
                            Button(action: {
                                isExercisePreferenceViewPresented = true
                            }) {
                                Text(section)
                                  .font(.headline)
                                  .foregroundColor(.themeStyle.theme.primary)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .background(Color.themeStyle.theme.green)
                    }
                    Spacer()
                }
                .navigationTitle("Preferences")
                .padding()
            }
            .sheet(isPresented: $isExercisePreferenceViewPresented) {
                let dependency = ExercisePreferenceViewModelDependencyImp(logger: Mocks.logger)
                let viewModel = ExercisePreferenceViewModel(dependency: dependency)
                ExericisePreferenceView(viewModel: viewModel).presentationDetents([.large])
            }
        }
    }
}

#Preview {
    let viewModel = PreferenceViewModel()
    return PreferenceView(viewModel: viewModel)
}
