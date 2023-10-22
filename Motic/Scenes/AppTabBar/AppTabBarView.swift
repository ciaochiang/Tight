//
//  AppTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

struct AppTabBarView: View {
    @State private var tabSelection: TabBarItemType = .home
    @State var isRecordViewPresented: Bool = false
    private var logger: CustomLogger
    private var wearableDeviceManager: WearableDeviceManager
    private var mainView: MainView
    
    init(logger: CustomLogger, wearableDeviceManager: WearableDeviceManager) {
        self.logger = logger
        self.wearableDeviceManager = wearableDeviceManager
        
        let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                    logger: logger)
        let viewModel = MainViewModel(dependency: dependency)
        mainView = MainView(viewModel: viewModel)
    }
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            mainView.tabBarItem(type: .home, selection: $tabSelection)

            Color.clear.tabBarItem(type: .record, selection: $tabSelection, disableContent: true) {
                isRecordViewPresented.toggle()
            }
            Color.green.tabBarItem(type: .preference, selection: $tabSelection)
        }
        .sheet(isPresented: $isRecordViewPresented) {
            let dependency = RecordViewModelDependencyImp(logger: logger,
                                                          activitySessionManager: ActivitySessionManager.shared,
                                                          wearableDeviceManager: wearableDeviceManager)
            let viewModel = RecordViewModel(dependency: dependency)
            RecordView(viewModel: viewModel, isPresented: $isRecordViewPresented)
                .presentationDetents([.large])
        }
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let logger = CustomLogger()
        let wearableDeviceManager = WearableDeviceManager(logger: logger)
        AppTabBarView(logger: logger, wearableDeviceManager: wearableDeviceManager)
    }
}
