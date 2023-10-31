//
//  AppTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

class AppTabBarViewModel: ObservableObject {
    var logger: CustomLogger
    var activitySessionManager: ActivitySessionManager
    var wearableDeviceManager: WearableDeviceManager
    
    init(logger: CustomLogger,
         activitySessionManager: ActivitySessionManager,
         wearableDeviceManager: WearableDeviceManager) {
        self.logger = logger
        self.activitySessionManager = activitySessionManager
        self.wearableDeviceManager = wearableDeviceManager
        self.wearableDeviceManager.delegate = self
        
        // Sync session status
        fetchWatchSessionStatus()
    }
    
    /**
     Get session status from Apple Watch
     */
    func fetchWatchSessionStatus() {
//        wearableDeviceManager.send(message: ["request": "currentStatus"]) { response in
//
//        }
    }
}

extension AppTabBarViewModel: WearableDeviceManagerDelegate {
    func didReceived(status: SessionStatus) {
        activitySessionManager.setSessionStatus(with: status)
    }
    
    func didReceived(heartRate: Double) {
        activitySessionManager.setHeartRate(with: heartRate)
    }
    
    func currentSessionStatus() -> SessionStatus {
        return activitySessionManager.sessionStatus
    }
}

struct AppTabBarView: View {
    @StateObject private var viewModel: AppTabBarViewModel
    @State private var tabSelection: TabBarItemType = .home
    @State var isRecordViewPresented: Bool = false
    private var logger: CustomLogger
    private var mainView: MainView
    
    init(viewModel: AppTabBarViewModel, logger: CustomLogger) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.logger = logger
        
        let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                    logger: logger)
        let viewModel = MainViewModel(dependency: dependency)
        mainView = MainView(viewModel: viewModel)
    }
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            mainView.tabBarItem(type: .home, selection: $tabSelection)

            Color.clear.tabBarItem(type: .record,
                                   selection: $tabSelection,
                                   disableContent: true) {
                isRecordViewPresented.toggle()
            }
            
            Color.green.tabBarItem(type: .preference, selection: $tabSelection)
        }
        .sheet(isPresented: $isRecordViewPresented) {
            let dependency = RecordViewModelDependencyImp(logger: logger,
                                                          activitySessionManager: viewModel.activitySessionManager,
                                                          wearableDeviceManager: viewModel.wearableDeviceManager)
            let viewModel = RecordViewModel(dependency: dependency)
            RecordView(viewModel: viewModel, isPresented: $isRecordViewPresented)
                .presentationDetents([.large])
        }
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppTabBarViewModel(logger: Mocks.logger,
                                           activitySessionManager: Mocks.activitySessionManager,
                                           wearableDeviceManager: Mocks.wearableDeviceManager)
        AppTabBarView(viewModel: viewModel, logger: Mocks.logger)
    }
}
