//
//  TightWatchApp.swift
//  TightWatch Watch App
//
//  Created by Ciao Chiang on 2024/1/21.
//

import SwiftUI

@main
struct TightWatch_Watch_AppApp: App {
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(viewModel)
    }
}
