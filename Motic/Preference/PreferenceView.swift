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
    
    init(viewModel: PreferenceViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 16) {
                    ForEach(viewModel.sections, id: \.self) { section in
                        HStack {
                          Text(section)
                            .font(.headline)
                            .foregroundColor(.themeStyle.theme.primary)
                          Spacer()
                        }
                        .frame(height: 40)
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    let viewModel = PreferenceViewModel()
    return PreferenceView(viewModel: viewModel)
}
