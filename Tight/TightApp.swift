//
//  TightApp.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UIKit
import WatchConnectivity
import ActivityKit
import AVFoundation

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
    private var logger = CustomLogger()
    @AppStorage(Constants.TRAINING_SESSION_CONTENT) private var sessionContent: Data?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        /// Activate Watch App
        if WCSession.isSupported() {
            WCSession.default.delegate = watchSessionDelegate
            WCSession.default.activate()
        }
        
        /// Setup Audio Configuration
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.log("Error setting up audio session: \(error.localizedDescription)", level: .error)
        }
                
        return true
    }
        
    func applicationWillTerminate(_ application: UIApplication) {
        /// Invoke `endSession` through `TrainingSessionMananger`
        TrainingSessionManager.shared.endSession()
        
        ///  Clean up `UserDefautls` session content if the app is terminated.
        sessionContent = nil
        
        /// Remove all existing live activity
        /// SeeAlso: https://forums.developer.apple.com/forums/thread/732418
        /// SeeAlso: https://www.reddit.com/r/iOSProgramming/comments/yci8o6/comment/k1onzhm/?utm_source=share&utm_medium=web3x&utm_name=oweb3xcss&utm_term=1&utm_content=share_button
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached {
            if let activity = Activity<TrainingSessionAttributes>.activities.first {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
       
        semaphore.wait()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        logger.log("app will enter foreground")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.log("app did enter background")
        
        /// Store current training session
        
    }
}

// MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .list, .sound])
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
