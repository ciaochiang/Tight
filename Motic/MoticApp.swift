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

  var body: some Scene {
    WindowGroup {
      if AccountManager.shared.isLoggedIn {
        MainView()
      } else {
        OnboardingView()
      }
    }
  }
}
