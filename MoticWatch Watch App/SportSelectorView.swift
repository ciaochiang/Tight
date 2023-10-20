//
//  SportSelectorView.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import SwiftUI

struct SportSelectorView: View {
    private var logger: CustomLogger
    @StateObject var viewModel: SportSelectorViewModel
    @StateObject var connectivity: WatchConnectivityProvider
    
    init(viewModel: SportSelectorViewModel, logger: CustomLogger) {
        self.logger = logger
        _viewModel = StateObject(wrappedValue: viewModel)
        _connectivity = StateObject(wrappedValue: viewModel.dependency.sportProvider.connectivity)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                VStack {
                    List {
                        ForEach(viewModel.allSports, id: \.self) { sport in
                            Text(sport.description)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchAllSports()
        }
    }
}

struct SportSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let logger = CustomLogger()
        let connectivity = WatchConnectivityProvider(logger: logger)
        let sportProvider = SportProvider(connectivity: connectivity)
        let depenedency = SportSelectorViewModelDependencyImp(logger: logger, sportProvider: sportProvider)
        let viewModel = SportSelectorViewModel(dependency: depenedency)
        SportSelectorView(viewModel: viewModel, logger: logger)
    }
}
