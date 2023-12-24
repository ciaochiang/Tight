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
    @StateObject var accountManager: AccountManager = AccountManager.shared
    @AppStorage("IS_ONBOARDING_COMPLETED") var isOnboardingCompleted: Bool = false
    private var logger: CustomLogger
    private var wearableDeviceManager: WearableDeviceManager
    private var experiementsProvider: ExperiementsProvider
    
    /// Swift data
    let container: ModelContainer = {
        let schema = Schema([ScheduledExercise.self, Plan.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    init() {
        self.logger = CustomLogger()
        
        let wearableDeviceManager = WearableDeviceManager(logger: logger)
        self.wearableDeviceManager = wearableDeviceManager
        self.experiementsProvider = ExperiementsProvider()
    }

    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                let coreDataManagerDependency = CoreDataManagerDependencyImp(logger: logger)
                let coreDataManager = CoreDataManager(dependency: coreDataManagerDependency)
                let viewModel = AppTabBarViewModel(logger: logger,
                                                   experimentsProvider: experiementsProvider)
                // Navigate to AppTabBar view
                AppTabBarView(viewModel: viewModel, logger: logger)
                    
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

extension Mocks {
    static var coreDataManager: CoreDataManager {
        let dependency = CoreDataManagerDependencyImp(logger: CustomLogger())
        return CoreDataManager(dependency: dependency)
    }
    
    static var wearableDeviceManager: WearableDeviceManager {
        return WearableDeviceManager(logger: CustomLogger())
    }
    
    static var activitySessionManager: ActivitySessionManager {
        return ActivitySessionManager.shared
    }
    
    static var experimentProvider: ExperiementsProvider {
        return ExperiementsProvider()
    }
}
