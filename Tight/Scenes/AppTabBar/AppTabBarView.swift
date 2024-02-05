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
    @EnvironmentObject private var logger: CustomLogger
    @EnvironmentObject private var experimentsProvider: ExperiementsProvider
    
    var body: some View {
        TabView {
            /// Create pivot main view
            let today = Date().today
            let mainViewModel = PivotMainViewModel(context: context, currentDate: today)
            PivotMainView(viewModel: mainViewModel).tabItem {
                Label(LocalizationProvider.plan.nameKey, systemImage: TabBarItemType.plan.iconName)
            }
            
            InsightHomeView().tabItem {
                Label(LocalizationProvider.insight.nameKey, systemImage: TabBarItemType.insight.iconName)
            }
                        
            /// Create PreferenceViews
            PreferenceView().tabItem {
                Label(LocalizationProvider.settings.nameKey, systemImage: TabBarItemType.setting.iconName)
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
    return AppTabBarView()
        .modelContainer(previewContainer.container)
        .environmentObject(ExperiementsProvider())
        .environmentObject(TrainingSessionManager())
        .environmentObject(Mocks.logger)
}
