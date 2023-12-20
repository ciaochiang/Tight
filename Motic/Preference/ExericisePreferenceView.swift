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
        VStack(spacing: 16) {
            topSeciton
            Spacer()
        }
        .padding()
    }
    
    
    var topSeciton: some View {
        HStack(spacing: 8) {
            
        }
        .padding(.vertical)
    }
}

#Preview {
    let dependency = ExercisePreferenceViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                              activtiySessionManager: Mocks.activitySessionManager,
                                                              logger: Mocks.logger)
    let viewModel = ExercisePreferenceViewModel(dependency: dependency)
    return ExericisePreferenceView(viewModel: viewModel)
}
