//
//  MoticApp.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import Firebase
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct MoticApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("IS_ONBOARDING_COMPLETED") var isOnboardingCompleted: Bool = false
    private var logger: CustomLogger
    private var experiementsProvider: ExperiementsProvider
    
    /// Swift data
    let container: ModelContainer = {
        let schema = Schema([ArrangedExercise.self, Plan.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    init() {
        self.logger = CustomLogger()
        self.experiementsProvider = ExperiementsProvider()
    }

    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                // Display to AppTabBar view
                AppTabBarView(logger: logger, experimentsProvider: experiementsProvider)
            } else {
                let viewModel = OnboardingViewModel(isOnboardingCompleted: $isOnboardingCompleted)
                OnboardingView(viewModel: viewModel)
            }
        }
        .onChange(of: isOnboardingCompleted, { _, newValue in
            guard newValue == true else { return }
            
            /// Store to user defaults
            UserDefaults.standard.setValue(newValue, forKey: "IS_ONBOARDING_COMPLETED")
        })
        
        /// Swift Data
        .modelContainer(container)
    }
}

