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
            let today = Date().today
            let mainViewModel = PivotMainViewModel(context: context, currentDate: today)
            PivotMainView(viewModel: mainViewModel,
                          trainingSessionManager: TrainingSessionManager.shared).tabItem {
                Label(LocalizationProvider.plan.nameKey, systemImage: TabBarItemType.plan.iconName)
            }
            
            /// Create PreferenceViews
            PreferenceView().tabItem {
                Label(LocalizationProvider.settings.nameKey, systemImage: TabBarItemType.more.iconName)
            }
        }
        .toolbarBackground(Color.themeStyle.theme.background, for: .tabBar)
        .onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor(Color.themeStyle.theme.background)
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    return AppTabBarView(logger: Mocks.logger, experimentsProvider: Mocks.experimentProvider)
        .modelContainer(previewContainer.container)
}
