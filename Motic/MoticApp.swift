//
//  MoticApp.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import Firebase

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
    var connectivity: ConnectivityProvider = ConnectivityProvider()
    private var logger = CustomLogger()

    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                // Navigate to AppTabBar view
                AppTabBarView(logger: logger)
                    
            } else {
                let viewModel = OnboardingViewModel(isOnboardingCompleted: $isOnboardingCompleted)
                OnboardingView(viewModel: viewModel)
            }
        }
        .onChange(of: isOnboardingCompleted, perform: { newValue in
            guard newValue == true else { return }
            
            // Store to user defaults
            UserDefaults.standard.setValue(newValue, forKey: "IS_ONBOARDING_COMPLETED")
        })
    }
}
