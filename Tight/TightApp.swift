//
//  TightApp.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI
import SwiftData
import FirebaseCore
import BackgroundTasks
import UIKit
import WatchConnectivity

// MARK: Migration Plan
enum TightMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [TightSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let watchSessionDelegate = WatchSessionDelegate()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        /// Activate Watch
        if WCSession.isSupported() {
            WCSession.default.delegate = watchSessionDelegate
            WCSession.default.activate()
        }
        
        return true
    }
}

@main
struct TightApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("IS_ONBOARDING_COMPLETED") var isOnboardingCompleted: Bool = false
    private var logger = CustomLogger()
    private var experiementsProvider = ExperiementsProvider()
    
    /// Swift data
    let container: ModelContainer = {
        let schema = Schema([ArrangedExercise.self, Plan.self])
        let configuratin = ModelConfiguration()
        
        let container = try! ModelContainer(
            for: schema,
            migrationPlan: TightMigrationPlan.self,
            configurations: [configuratin])
        return container
    }()
    
    init() {
        
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
