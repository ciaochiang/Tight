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
    var experimentsProvider: ExperiementsProvider
    
    init(logger: CustomLogger,
         experimentsProvider: ExperiementsProvider) {
        self.logger = logger
        self.experimentsProvider = experimentsProvider

    }
}

struct AppTabBarView: View {
    @Environment(\.modelContext) var context
    @StateObject private var viewModel: AppTabBarViewModel
    @State private var tabSelection: TabBarItemType = .plan
    
    private var logger: CustomLogger
    
    init(viewModel: AppTabBarViewModel, logger: CustomLogger) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.logger = logger
    }
    
    var body: some View {
        TabView {
            /// Create pivot main view
            let mainViewModel = PivotMainViewModel()
            PivotMainView(viewModel: mainViewModel).tabItem {
                Label("Plan", systemImage: TabBarItemType.plan.iconName)
            }
            
            /// Create PreferenceViews
            let preferenceViewModel = PreferenceViewModel()
            PreferenceView(viewModel: preferenceViewModel).tabItem {
                Label("Settings", systemImage: TabBarItemType.more.iconName)
            }
        }
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppTabBarViewModel(logger: Mocks.logger,
                                           experimentsProvider: Mocks.experimentProvider)
        let previewContainer = PreviewContainer([ScheduledExercise.self])
        AppTabBarView(viewModel: viewModel, logger: Mocks.logger)
            .modelContainer(previewContainer.container)
        
    }
}
