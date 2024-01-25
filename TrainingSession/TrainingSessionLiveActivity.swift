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
    
    static var title: LocalizedStringResource = "Skip Resting"
    static var description = IntentDescription("Skip resting and go to next set")
    
    func perform() async throws -> some IntentResult {
        /// Update Database
        TrainingSessionManager.shared.endRest()
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct StopTrainingSession: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Stop Training Session"
    static var description = IntentDescription("Stop training session and reset session")
    
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
                if context.state.completionType > -1 {  /// -1 is initial state
                    Text(context.state.completionType == 0
                         ? LocalizationProvider.abortCompletionMessage.nameKey
                         : LocalizationProvider.doneCompletionMessage.nameKey)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 40)
                        .padding(.horizontal)
                } else {
                    HStack(spacing: 16) {
                        SetsProgressView(context: context)
                        ExerciseInfoView(context: context)
                        ElapsedTimeView(context: context)
                    }
                    
                    ControlsView(context: context)
                    
                    LinearProgressView(progress: context.state.totoalProgress)
                        .cornerRadius(6.0)
                        .padding(.bottom, 4)
                }
            }
            .padding()
            .activitySystemActionForegroundColor(Color.themeStyle.theme.accent)
            .activityBackgroundTint(Color.themeStyle.theme.background)
            .background(Color.themeStyle.theme.background)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.startTime, style: .timer)
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 2)
                        .contentTransition(.numericText())
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    SetsProgressView(context: context)
                        .frame(width: 28, height: 28)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        LinearProgressView(progress: context.state.totoalProgress)
                        DynamicIslandExerciseInfoView(context: context)
                            .padding(.bottom, 8)
                        ControlsView(context: context)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                }
            } compactLeading: {
                HStack {
                    CircularProgressView(progress: context.state.totoalProgress)
                        .progressViewStyle(.circular)
                    Text(context.state.startTime, style: .timer)
                        .contentTransition(.numericText())
                }
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
        ProgressView(value: context.state.currentSetsProgress) {
            Text("\(context.state.indexOfSet + 1)")
        }
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
    }
    
    @ViewBuilder
    func ExerciseInfoView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack(spacing: 4) {
            if context.state.restStartTime != nil {
                Text(LocalizationProvider.breakTimeTitle.nameKey)
                    .font(.headline)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            else {
                Text(context.state.currentExerciseName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let weightUnit = WeightUnit(rawValue: context.state.weightUnit) {
                Text("\(Int(context.state.weight))\(weightUnit.name) x \(Int(context.state.repetition))")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.footnote)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    func DynamicIslandExerciseInfoView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        HStack(spacing: 4) {
            if context.state.restStartTime != nil {
                Text(LocalizationProvider.breakTimeTitle.nameKey)
                    .font(.headline)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            else {
                Text(context.state.currentExerciseName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let weightUnit = WeightUnit(rawValue: context.state.weightUnit) {
                Text("\(Int(context.state.weight))\(weightUnit.name) x \(Int(context.state.repetition))")
                    .frame(maxWidth: 80, alignment: .trailing)
                    .font(.footnote)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func ElapsedTimeView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        VStack {
            if let restStartTime = context.state.restStartTime,
               let restIntervals = context.state.restIntervals {
                Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restIntervals), countsDown: true)
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                    .contentTransition(.numericText(countsDown: true))
            }
            else {
                Text(context.state.startTime, style: .timer)
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .contentTransition(.numericText())
            }
        }
    }
    
    @ViewBuilder
    func ControlsView(context: ActivityViewContext<TrainingSessionAttributes>) -> some View {
        HStack {
            Button(intent: StopTrainingSession()) {
                Image(systemName: "stop.fill")
                    .padding(.horizontal, 60)
                    .padding(.vertical, 4)
            }
            .tint(Color.themeStyle.theme.accent)
            
            Spacer()
            
            if context.state.restStartTime != nil {
                Button(intent: SkipRest()) {
                    Image(systemName: "chevron.forward.2")
                        .padding(.horizontal, 60)
                        .padding(.vertical, 4)
                }
                .tint(Color.themeStyle.theme.secondaryTextColor)
            }
            else {
                Button(intent: CompleteSet(id: context.state.currentExerciseID)) {
                    Image(systemName: "checkmark.square.fill")
                        .padding(.horizontal, 60)
                        .padding(.vertical, 4)
                }
                .tint(Color.themeStyle.theme.secondaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    func LinearProgressView(progress: Double) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(.linear)
            .background(Color.themeStyle.theme.secondaryBackground)
            .tint(Color.themeStyle.theme.accent)
            .animation(.easeInOut, value: progress)
    }
    
    @ViewBuilder
    func CircularProgressView(progress: Double) -> some View {
        let percentage = progress * 100
        
        ProgressView(value: progress) {
            Text(String(format: "%.0f", percentage))
        }
            .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
            .animation(.easeInOut, value: progress)
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
        TrainingSessionAttributes()
    }
}

extension TrainingSessionAttributes.ContentState {
    fileprivate static var initial: TrainingSessionAttributes.ContentState {
        TrainingSessionAttributes.ContentState(currentExerciseID: "123",
                                               currentExerciseName: "Bench Press",
                                               weight: 50,
                                               weightUnit: 0,
                                               repetition: 10,
                                               startTime: .now,
                                               indexOfSet: 0,
                                               currentSetsProgress: 0.3,
                                               totoalProgress: 0.3,
                                               completionType: -1)
     }
     
     fileprivate static var progressing: TrainingSessionAttributes.ContentState {
         TrainingSessionAttributes.ContentState(currentExerciseID: "234",
                                                currentExerciseName: "Leg Extension",
                                                weight: 50,
                                                weightUnit: 0,
                                                repetition: 10,
                                                startTime: .now,
                                                indexOfSet: 0,
                                                currentSetsProgress: 0.3,
                                                totoalProgress: 0.3,
                                                completionType: -1)
     }
}

#Preview("Notification", as: .content, using: TrainingSessionAttributes.preview) {
   TrainingSessionLiveActivity()
} contentStates: {
    TrainingSessionAttributes.ContentState.initial
    TrainingSessionAttributes.ContentState.progressing
}
