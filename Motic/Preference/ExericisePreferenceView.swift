//
//  ExericisePreferenceView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/19.
//

import SwiftUI

struct ExericisePreferenceView: View {
    @StateObject var viewModel: ExercisePreferenceViewModel
    
    init(viewModel: ExercisePreferenceViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.allExercises, id: \.self) { exercise in
                    Text(exercise.name)
                }
            }
        }
    }
}

#Preview {
    let dependency = ExercisePreferenceViewModelDependencyImp(logger: Mocks.logger)
    let viewModel = ExercisePreferenceViewModel(dependency: dependency)
    return ExericisePreferenceView(viewModel: viewModel)
}
