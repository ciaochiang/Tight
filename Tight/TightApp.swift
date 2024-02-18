//
//  TightApp.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI
import SwiftData
import Firebase
import UIKit
import WatchConnectivity
import ActivityKit

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
    lazy var logger = TTLogger()
    lazy var trainingSessionManager = TrainingSessionManager()
    @AppStorage(Constants.TRAINING_SESSION_CONTENT) private var sessionContent: Data?
    
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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        /// Activate Watch App
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        /// Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleIntentCompleteNotification(_:)), name: .intentComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleIntentSkipNotification(_:)), name: .intentSkip, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleIntentStopNotification(_:)), name: .intentStop, object: nil)
                
        return true
    }
        
    func applicationWillTerminate(_ application: UIApplication) {
        /// Invoke `endSession` through `TrainingSessionMananger`
        trainingSessionManager.endSession()
        
        ///  Clean up `UserDefautls` session content if the app is terminated.
        sessionContent = nil
        
        /// Remove all existing live activity
        /// SeeAlso: https://forums.developer.apple.com/forums/thread/732418
        /// SeeAlso: https://www.reddit.com/r/iOSProgramming/comments/yci8o6/comment/k1onzhm/?utm_source=share&utm_medium=web3x&utm_name=oweb3xcss&utm_term=1&utm_content=share_button
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached {
            if let activity = Activity<LiveActivityAttributes>.activities.first {
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
    
    // MARK: Live Activity Intent
    @objc func handleIntentCompleteNotification(_ notification: Notification) {
        guard let exerciseID = notification.userInfo?["exerciseID"] as? String else { return }
        
        DispatchQueue.main.async {
            self.trainingSessionManager.completeCurrentSet(exerciseID: exerciseID)
        }
    }
    
    @objc func handleIntentSkipNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.trainingSessionManager.endRest()
        }
    }
    
    @objc func handleIntentStopNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.trainingSessionManager.endSession()
        }
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
    private var experiementsProvider = ExperiementsProvider()

    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                // Display to AppTabBar view
                AppTabBarView()
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
        .modelContainer(delegate.container)
        .environmentObject(delegate.trainingSessionManager)
        .environmentObject(delegate.logger)
        .environmentObject(experiementsProvider)
    }
}
