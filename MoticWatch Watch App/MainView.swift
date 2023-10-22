//
//  MainView.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State var isRecording: Bool = false
    @State var isPaused: Bool = false
    
    init(viewModel: MainViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if isRecording == false && isPaused == false {
                playButtonView
            } else {
                VStack {
                    pauseButtonView
                    stopButtonView
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
//            workoutSessionManager.authorizeHealthKit()
        }
    }
    
    var playButtonView: some View {
        VStack {
            Image(systemName: "play")
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Color.green)
        .cornerRadius(16)
        .padding()
        .onTapGesture {
            isRecording.toggle()
            
//            if isRecording {
//                workoutSessionManager.createWorkoutSession()
//            }
        }
    }
    
    var pauseButtonView: some View {
        VStack {
            Image(systemName: isPaused ? "arrow.triangle.2.circlepath" : "pause")
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Color.yellow)
        .cornerRadius(16)
        .padding()
        .onTapGesture {
            isPaused.toggle()
        }
    }
    
    var stopButtonView: some View {
        VStack {
            Image(systemName: "stop")
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(16)
        .padding()
        .onTapGesture {
            isRecording = false
//            workoutSessionManager.stopWorkoutSession()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let logger = CustomLogger()
        let connectivity = WatchConnectivityProvider(logger: logger)
        let workoutSessionManager = WorkoutSessionManager()
        let dependency = MainViewModelDependencyImp(logger: logger,
                                                    connectivity: connectivity,
                                                    workoutSessionManager: workoutSessionManager)
        let viewModel = MainViewModel(dependency: dependency)
        MainView(viewModel: viewModel)
    }
}
