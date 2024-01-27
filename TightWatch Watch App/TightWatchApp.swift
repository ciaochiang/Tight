//
//  TightWatchApp.swift
//  TightWatch Watch App
//
//  Created by Ciao Chiang on 2024/1/21.
//

import SwiftUI

@main
struct TightWatch_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            switch newValue {
            case .active:
                // App became active
                print("App is active")
            case .inactive:
                // App became inactive
                print("App is inactive")
            case .background:
                // App is in the background
                print("App is in the background")
            @unknown default:
                // Handle any future lifecycle phases
                break
            }
        })
        .environmentObject(viewModel)
    }
}
