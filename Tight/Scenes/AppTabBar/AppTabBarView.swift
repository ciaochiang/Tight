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
    @State private var selection: Int = 0
    
    
    var body: some View {
        TabView(selection: $selection) {
            /// Create pivot main view
            let today = Date().today
            let mainViewModel = MainViewModel(context: context, currentDate: today)
            MainView(viewModel: mainViewModel).tabItem {
                Label(LocalizationProvider.plan.nameKey, systemImage: TabBarItemType.plan.iconName)
            }.tag(0)
            
            InsightHomeView().tabItem {
                Label(LocalizationProvider.insight.nameKey, systemImage: TabBarItemType.trend.iconName)
            }.tag(1)
                        
            /// Create PreferenceViews
            PreferenceView().tabItem {
                Label(LocalizationProvider.settings.nameKey, systemImage: TabBarItemType.setting.iconName)
            }.tag(2)
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
