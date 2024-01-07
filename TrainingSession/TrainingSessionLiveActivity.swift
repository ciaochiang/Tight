//
//  TrainingSessionLiveActivity.swift
//  TrainingSession
//
//  Created by Ciao Chiang on 2024/1/5.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct CompleteExercise: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Complete Current Exercise"
    static var description = IntentDescription("Mark current exercise as completed and start rest")
    
    @Parameter(title: "Exercise ID")
    var id: String
    
    init() {
        
    }
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.completeCurrentExercise(exerciseID: id)
        return .result()
    }
}

struct StopTrainingSession: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Stop Training Session"
    static var description = IntentDescription("Stop current training session and reset timer")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.stopTrainingSession()
        return .result()
    }
}

struct TrainingSessionLiveActivity: Widget {
    @State private var isAnimating: Bool = false
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrainingSessionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 16) {
                HStack {
                    ElapsedTimeView(context: context)
                    Spacer()
                    
                    if context.state.nextExercise != "" {
                        Text("Next: \(context.state.nextExercise)")
                            .foregroundStyle(Color.themeStyle.theme.secondaryTextColor.opacity(0.5))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .padding(.horizontal)
                
                StagesView(totalExerciseCount: context.state.totalExerciseCount,
                           currentStage: context.state.currentStage)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                
                ControlsView(context: context)
                    .padding(.bottom)

            }
            .frame(maxWidth: .infinity)
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.themeStyle.theme.accent)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text(context.state.currentExercise)
                            .font(.title3)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 16) {
                        Text("\(context.state.elapsedTime.formatIntervalToMinutesSeconds)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        StagesView(totalExerciseCount: context.state.totalExerciseCount,
                                   currentStage: context.state.currentStage)

                        HStack {
                            ExerciseInfoView(context: context)
                            Spacer()
                            ControlsView(context: context)
                        }
                    }
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.elapsedTime)")
            } minimal: {
                Text("Time: \(context.state.elapsedTime)")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
    
    @ViewBuilder
    func ExerciseInfoView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.state.currentExercise)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("\(Int(context.state.weight))kg x \(Int(context.state.repetition))")
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack {
            Text("\(context.state.elapsedTime.formatIntervalToMinutesSeconds)")
                .font(.title)
                .fontWeight(.bold)
                .tracking(1.4)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText(value: context.state.elapsedTime))
        }
    }
    
    @ViewBuilder
    func ControlsView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        HStack {
            ExerciseInfoView(context: context)
            Spacer()
            
            Button(intent: StopTrainingSession()) {
                Image(systemName: "stop.fill")
            }
            .tint(Color.themeStyle.theme.accent)
            
            Button(intent: CompleteExercise(id: context.state.currentExerciseID)) {
                Image(systemName: "checkmark.square.fill")
            }
            .tint(Color.themeStyle.theme.secondaryAccent)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func StagesView(totalExerciseCount: Int, currentStage: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.3))
                .frame(height: 4)
                .padding(.horizontal, 4)
            
            GeometryReader(content: { geometry in
                let offsetRatio = CGFloat(currentStage) / CGFloat(totalExerciseCount - 1)
                Rectangle()
                    .fill(Color.themeStyle.theme.accent)
                    .frame(height: 4)
                    .frame(width: (geometry.frame(in: .global).width * offsetRatio) - 8, alignment: .leading)
                    .padding(.horizontal, 4)
                    .offset(y: 8)
            })
            
            HStack {
                ForEach(0..<totalExerciseCount, id: \.self) { i in
                    BreathCircleView(isCurrentStage: i == currentStage, isPendingStage: i > currentStage)

                    if i < totalExerciseCount - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}

struct BreathCircleView: View {
    var isCurrentStage: Bool
    var isPendingStage: Bool
    
    @State var animate: Bool = false
    @State var scale = 1.0

    
    var body: some View {
        ZStack {
            if isCurrentStage {
                Circle().fill(Color.themeStyle.theme.accent.opacity(0.25)).shadow(color: .white.opacity(0.7), radius: 5).frame(width: 20, height: 20)
                Circle().fill(Color.themeStyle.theme.accent.opacity(0.45)).frame(width: 16, height: 16)
            }

            Circle().fill(isPendingStage ? .gray : Color.themeStyle.theme.accent).frame(width: 12, height: 12)
        }
    }
}

extension TrainingSessionAttributes {
    fileprivate static var preview: TrainingSessionAttributes {
        TrainingSessionAttributes(name: "World")
    }
}

extension TrainingSessionAttributes.ContentState {
    fileprivate static var initial: TrainingSessionAttributes.ContentState {
        TrainingSessionAttributes.ContentState(totalExerciseCount: 5, currentStage: 0, currentExerciseID: "123", currentExercise: "Bench Press", nextExercise: "Pull Up", weight: 40, repetition: 12, restInterval: 90, elapsedTime: 0)
     }
     
     fileprivate static var progressing: TrainingSessionAttributes.ContentState {
         TrainingSessionAttributes.ContentState(totalExerciseCount: 5, currentStage: 1, currentExerciseID: "234", currentExercise: "Bench Press", nextExercise: "Pull Up", weight: 40, repetition: 12, restInterval: 90, elapsedTime: 120)
     }
}

#Preview("Notification", as: .content, using: TrainingSessionAttributes.preview) {
   TrainingSessionLiveActivity()
} contentStates: {
    TrainingSessionAttributes.ContentState.initial
    TrainingSessionAttributes.ContentState.progressing
}
