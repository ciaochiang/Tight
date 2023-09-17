//
//  MoticApp.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

@main
struct MoticApp: App {
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
