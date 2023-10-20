//
//  SportSelectorView.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import SwiftUI

struct SportSelectorView: View {
    @StateObject var viewModel: SportSelectorViewModel
    
    init(viewModel: SportSelectorViewModel) {
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
                print("load sport")
                viewModel.fetchAllSports()
            }
            .opacity(viewModel.allSports.count > 0 ? 0 : 1)
        }
    }
}

struct SportSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let logger = Logger.init(configuration: AppConfiguration.loggerConfig)
        let connectivity = WatchConnectivityProvider()
        let sportProvider = SportProvider(connectivity: connectivity)
        let depenedency = SportSelectorViewModelDependencyImp(logger: logger, sportProvider: sportProvider)
        let viewModel = SportSelectorViewModel(dependency: depenedency)
        SportSelectorView(viewModel: viewModel)
    }
}
