//
//  AppTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

struct AppTabBarView: View {
    @State private var tabSelection: TabBarItemType = .home
    private var mainView: MainView
    
    init() {
        let logger = Logger(configuration: AppConfiguration.loggerConfig)
        let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                    logger: logger)
        let viewModel = MainViewModel(dependency: dependency)
        mainView = MainView(viewModel: viewModel)
    }
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            mainView.tabBarItem(type: .home, selection: $tabSelection)

            Color.clear.tabBarItem(type: .record, selection: $tabSelection, disableContent: true) {

            }
            Color.green.tabBarItem(type: .preference, selection: $tabSelection)
        }
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabBarView()
    }
}
