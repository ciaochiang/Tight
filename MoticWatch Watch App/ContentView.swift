//
//  ContentView.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI

struct ContentView: View {
  @StateObject var workoutSessionManager: WorkoutSessionManager = WorkoutSessionManager()
  @StateObject var viewModel: ContentViewModel = ContentViewModel()
  
  var body: some View {
    List {
      ForEach(viewModel.supportedActivityTypes, id: \.self) { activityType in
        Button(viewModel.getActivityName(activityType: activityType),
               action: {
//          workoutSessionManager.workoutSessionIsStarted
//          ? workoutSessionManager.stopWorkoutSession()
//          : workoutSessionManager.createWorkoutSession(activityType: .running)
        })
//          .frame(minWidth: 0, maxWidth: .infinity)
//          .background(workoutSessionManager.workoutSessionIsStarted ? Color.red : Color.green)
//          .cornerRadius(10)
      }
//      ForEach(viewModel.supportedActivityTypes, id: \.self) { activity in
//
//
//      }
    }
    .onAppear {
      workoutSessionManager.authorizeHealthKit()
    }
    
//    VStack(alignment: .leading) {
//
//      Button(workoutSessionManager.workoutSessionIsStarted ? "Stop" : "Start",
//             action: {
//        workoutSessionManager.workoutSessionIsStarted
//        ? workoutSessionManager.stopWorkoutSession()
//        : workoutSessionManager.createWorkoutSession(activityType: .running)
//      })
//        .frame(minWidth: 0, maxWidth: .infinity)
//        .background(workoutSessionManager.workoutSessionIsStarted ? Color.red : Color.green)
//        .cornerRadius(10)
//    }
//    .frame(maxHeight: .infinity)
//    .onAppear {
//      workoutSessionManager.authorizeHealthKit()
//    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
