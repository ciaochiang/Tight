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
    
    init(viewModel: SportSelectorViewModel, logger: CustomLogger) {
        self.logger = logger
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(viewModel.allSports, id: \.self) { sport in
                        Text(sport.description)
                    }
                }
            }
            
            Button("load") {
                logger.log("click load button", level: .debug)
                viewModel.fetchAllSports()
            }
            .opacity(viewModel.allSports.count > 0 ? 0 : 1)
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
