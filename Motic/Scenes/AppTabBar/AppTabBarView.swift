//
//  AppTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI
import SwiftData

struct AppTabBarView: View {
    @Environment(\.modelContext) private var context: ModelContext
    private var logger: CustomLogger
    private var experimentsProvider: ExperiementsProvider
    
    init(logger: CustomLogger, experimentsProvider: ExperiementsProvider) {
        self.logger = logger
        self.experimentsProvider = experimentsProvider
    }
    
    var body: some View {
        TabView {
            /// Create pivot main view
            let mainViewModel = PivotMainViewModel(context: context)
            PivotMainView(viewModel: mainViewModel).tabItem {
                Label("Plan", systemImage: TabBarItemType.plan.iconName)
            }
            
            /// Create PreferenceViews
            PreferenceView().tabItem {
                Label("Settings", systemImage: TabBarItemType.more.iconName)
            }
        }
    }
}

struct AppTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContainer = PreviewContainer([ScheduledExercise.self])
        AppTabBarView(logger: Mocks.logger, experimentsProvider: Mocks.experimentProvider)
            .modelContainer(previewContainer.container)
        
    }
}
