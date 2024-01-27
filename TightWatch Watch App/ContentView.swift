//
//  ContentView.swift
//  TightWatch Watch App
//
//  Created by Ciao Chiang on 2024/1/21.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        if viewModel.state == .notStarted {
            LaunchView()
        } else {
            VStack(spacing: 16) {
                HStack {
                    ExerciseSetProgressView()
                    ExerciseTimeView()
                }
                
                Spacer()
                ExerciseInfoView()
                ExerciseControlsView()
            }
            .onAppear {
                /// Start session
                viewModel.startSession()
            }
            .onChange(of: viewModel.state) { oldValue, newValue in
                if newValue == .aborted || newValue == .finshed {
                    viewModel.endSession()
                }
            }
        }
    }
    
    @ViewBuilder
    func LaunchView() -> some View {
        VStack {
            Text(LocalizationProvider.watchLaunchHeading.nameKey)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    func ExerciseSetProgressView() -> some View {
        if let indexOfSet = viewModel.indexOfSet,
            let currentSetsProgress = viewModel.currentSetsProgress {
            ProgressView(value: currentSetsProgress) {
                Text("\(indexOfSet + 1)")
            }
            .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
        }
    }
    
    @ViewBuilder
    func ExerciseTimeView() -> some View {
        if viewModel.state == .resting,
           let restStartTime = viewModel.restStartTime,
           let restIntervals = viewModel.restIntervals, restIntervals > 0 {
            Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restIntervals), countsDown: true)
                .font(.title)
                .fontWeight(.bold)
                .tracking(4.0)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                .foregroundStyle(Color.themeStyle.theme.watchSecondaryTextColor)
                .contentTransition(.numericText())
        }
        else if let startTime = viewModel.startTime {
            Text(startTime, style: .timer)
                .font(.title)
                .fontWeight(.bold)
                .tracking(4.0)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                .foregroundStyle(Color.themeStyle.theme.accent)
                .contentTransition(.numericText())
        }
    }
    
    @ViewBuilder
    func ExerciseInfoView() -> some View {
        VStack {
            Text(viewModel.exerciseName ?? "")
                .font(.headline)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.themeStyle.theme.watchPrimaryTextColor)


            if let weight = viewModel.weight,
                let weightUnit = viewModel.weightUnit,
                let reps = viewModel.repetitions {
                Text("\(Int(weight))\(weightUnit.name) x \(Int(reps))")
                    .font(.subheadline)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .foregroundStyle(Color.themeStyle.theme.watchSecondaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    func ExerciseControlsView() -> some View {
        HStack {
            Button(action: {
                viewModel.onClickEnd()
            }) {
                Image(systemName: "stop.fill")
            }
            .tint(Color.themeStyle.theme.accent)
            .disabled(viewModel.isInteractaable == false)
            
            Button(action: {
                viewModel.state == .resting ? viewModel.onClickSkip() : viewModel.onClickComplete()
            }) {
                Image(systemName: viewModel.state == .resting ? "chevron.forward.2" : "checkmark")
            }
            .disabled(viewModel.isInteractaable == false)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentViewModel())
}
