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

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CompleteSet: LiveActivityIntent {
    
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
        TrainingSessionManager.shared.completeCurrentSet(exerciseID: id)
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SkipRest: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Skip Current Rest"
    static var description = IntentDescription("Skip rest and jump to next set")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.skipRest()
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
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
                if context.state.completionMessage != ""  {
                    Text(context.state.completionMessage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 40)
                        .padding(.horizontal)
                } else {
                    HStack {
                        ElapsedTimeView(context: context)
                        Spacer()
                        SetsProgressView(context: context)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .padding(.horizontal)
                    
                    StagesView(totalExerciseCount: context.state.totalExerciseCount,
                               currentStage: context.state.currentStage)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    
                    ControlsView(context: context)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity)
            .activitySystemActionForegroundColor(Color.themeStyle.theme.accent)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.state.elapsedTime.formatIntervalToMinutesSeconds)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    SetsProgressView(context: context)
                        .frame(width: 28, height: 28)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        StagesView(totalExerciseCount: context.state.totalExerciseCount,
                                   currentStage: context.state.currentStage)
                        ControlsView(context: context)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding(.bottom)
                }
            } compactLeading: {
                Text("\(context.state.elapsedTime.formatIntervalToMinutesSeconds)")
            } compactTrailing: {
                SetsProgressView(context: context)
                    .frame(width: 24, height: 24)
            } minimal: {
                SetsProgressView(context: context)
                    .frame(width: 24, height: 24)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.themeStyle.theme.accent)
        }
    }
    
    @ViewBuilder
    func SetsProgressView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        ProgressView(value: CGFloat(context.state.indexOfSet) / CGFloat(context.state.totalSetsCount)) {
            Text("\(context.state.indexOfSet)")
        }
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
    }
    
    @ViewBuilder
    func ExerciseInfoView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack(spacing: 8) {
            if context.state.restIntervals > 0 {
                Text("Take a break!")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Stay hydrated")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
            else {
                Text(context.state.currentExercise)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(Int(context.state.weight))kg x \(Int(context.state.repetition))")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack {
            if context.state.restIntervals > 0 {
                Text( "\(context.state.restIntervals.formatIntervalToMinutesSeconds)")
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.blue)
                    .contentTransition(.numericText(value: context.state.restIntervals))
            }
            else {
                Text( "\(context.state.elapsedTime.formatIntervalToMinutesSeconds)")
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .contentTransition(.numericText(value: context.state.elapsedTime))
            }
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
            
            if context.state.restIntervals > 0 {
                Button(intent: SkipRest()) {
                    Image(systemName: "chevron.forward.2")
                }
                .tint(Color.blue)
            }
            else {
                Button(intent: CompleteSet(id: context.state.currentExerciseID)) {
                    Image(systemName: "checkmark.square.fill")
                }
                .tint(Color.themeStyle.theme.secondaryAccent)
            }
        }
    }

    @ViewBuilder
    func StagesView(totalExerciseCount: Int, currentStage: Int) -> some View {
        GeometryReader(content: { geometry in
            let progress = CGFloat(currentStage) / CGFloat(totalExerciseCount - 1)
            
            ZStack {
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(height: 4)
                    .padding(.horizontal, 4)
                
                Rectangle()
                    .fill(Color.themeStyle.theme.accent)
                    .frame(height: 4)
                    .frame(width: (geometry.frame(in: .global).width * progress), alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                
                HStack {
                    ForEach(0..<totalExerciseCount, id: \.self) { i in
                        BreathCircleView(isCurrentStage: i == currentStage, isPendingStage: i > currentStage)

                        if i < totalExerciseCount - 1 {
                            Spacer()
                        }
                    }
                }
            }
        })
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
        TrainingSessionAttributes.ContentState(totalExerciseCount: 5,
                                               currentStage: 0,
                                               currentExerciseID: "123",
                                               currentExercise: "Bench Press",
                                               totalSetsCount: 3,
                                               indexOfSet: 1,
                                               weight: 40,
                                               repetition: 12,
                                               restIntervals: 10,
                                               elapsedTime: 0,
                                               completionMessage: "")
     }
     
     fileprivate static var progressing: TrainingSessionAttributes.ContentState {
         TrainingSessionAttributes.ContentState(totalExerciseCount: 5, 
                                                currentStage: 1,
                                                currentExerciseID: "234",
                                                currentExercise: "Bench Press",
                                                totalSetsCount: 3,
                                                indexOfSet: 2,
                                                weight: 40,
                                                repetition: 12,
                                                restIntervals: 0,
                                                elapsedTime: 120,
                                                completionMessage: "")
     }
}

#Preview("Notification", as: .content, using: TrainingSessionAttributes.preview) {
   TrainingSessionLiveActivity()
} contentStates: {
    TrainingSessionAttributes.ContentState.initial
    TrainingSessionAttributes.ContentState.progressing
}
