//
//  AppTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI
import SwiftData

class AppTabBarViewModel: ObservableObject {
    var logger: CustomLogger
    var activitySessionManager: ActivitySessionManager
    var wearableDeviceManager: WearableDeviceManager
    var experimentsProvider: ExperiementsProvider
    @Published var isRecordViewPresented: Bool
    
    init(logger: CustomLogger,
         activitySessionManager: ActivitySessionManager,
         wearableDeviceManager: WearableDeviceManager,
         experimentsProvider: ExperiementsProvider) {
        self.logger = logger
        self.activitySessionManager = activitySessionManager
        self.wearableDeviceManager = wearableDeviceManager
        self.experimentsProvider = experimentsProvider
        _isRecordViewPresented = Published(wrappedValue: false)
    }
}

struct AppTabBarView: View {
    @StateObject private var viewModel: AppTabBarViewModel
    @State private var tabSelection: TabBarItemType = .home
    private var logger: CustomLogger
    
    init(viewModel: AppTabBarViewModel, logger: CustomLogger) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.logger = logger
    }
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            
            /// Create MainView
//            let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
//                                                        activtiySessionManager: viewModel.activitySessionManager,
//                                                        logger: logger)
//            let mainViewModel = MainViewModel(dependency: dependency,
//                                              isRecordViewPresented: $viewModel.isRecordViewPresented)
//            MainView(viewModel: mainViewModel).tabBarItem(type: .home, selection: $tabSelection)
            
            /// Create pivot main view
            let mainViewModel = PivotMainViewModel()
            PivotMainView(viewModel: mainViewModel).tabBarItem(type: .home, selection: $tabSelection)

            /// Craeat RecordView
            /*
            if viewModel.experimentsProvider.isRecordingEnabled {
                Color.clear.tabBarItem(type: .record,
                                       selection: $tabSelection,
                                       disableContent: true) {
                    viewModel.isRecordViewPresented.toggle()
                }
            }
            */
            
            /// Create PreferenceViews
            let preferenceViewModel = PreferenceViewModel()
            PreferenceView(viewModel: preferenceViewModel).tabBarItem(type: .preference, selection: $tabSelection)
        }
        
        /// NOTE:  Pivot to focus on strength training
        /*
        .sheet(isPresented: $viewModel.isRecordViewPresented) {
            let dependency = RecordViewModelDependencyImp(logger: logger,
                                                          activitySessionManager: viewModel.activitySessionManager,
                                                          wearableDeviceManager: viewModel.wearableDeviceManager)
            let viewModel = RecordViewModel(dependency: dependency)
            RecordView(viewModel: viewModel, isPresented: $viewModel.isRecordViewPresented)
                .presentationDetents([.large])
        }
         */
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppTabBarViewModel(logger: Mocks.logger,
                                           activitySessionManager: Mocks.activitySessionManager,
                                           wearableDeviceManager: Mocks.wearableDeviceManager,
                                           experimentsProvider: Mocks.experimentProvider)
        let previewContainer = PreviewContainer([ScheduledExercise.self])
        AppTabBarView(viewModel: viewModel, logger: Mocks.logger)
            .modelContainer(previewContainer.container)
        
    }
}
