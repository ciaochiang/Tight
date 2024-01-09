//
//  PivotMainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import Foundation
import SwiftUI
import SwiftData

struct PivotMainView: View {
    @Environment(\.modelContext) var context
    @StateObject var viewModel: PivotMainViewModel
    @StateObject var trainingSessionManager: TrainingSessionManager
    @State private var isArrangingExercise: Bool = false
    @State private var isImporting: Bool = false
    @State private var exerciseToEdit: ArrangedExercise?
    
        
    /// Animation  namespace
    @Namespace private var animation
    
    init(viewModel: PivotMainViewModel, trainingSessionManager: TrainingSessionManager) {
        _viewModel = .init(wrappedValue: viewModel)
        _trainingSessionManager = .init(wrappedValue: trainingSessionManager)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderView()
            TrainingSessionView()
            
            ///  Scheduled exercises
            if viewModel.currentPlan?.arrangedExercises.isEmpty == true {
                PlaceholderView()
                    .veriticalSpacing(.center)
                    .horizontalSpacing(.center)
                    .offset(y: -32)
            }
            else {
                ArrangedExercisesView()
            }
        }
        .background(Color.themeStyle.theme.background)
        .veriticalSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                isArrangingExercise.toggle()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.themeStyle.theme.accent.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 5, y: 5)), in: .circle)
                
            }
            .padding(16)
            .offset(y: -48)
        })
        .onAppear(perform: {
            if viewModel.weeks.isEmpty {
                viewModel.loadWeeks()
            }
        })
        
        // MARK: Bottom Sheet
        .sheet(isPresented: $isArrangingExercise, content: {
            if let plan = viewModel.currentPlan {
                CreateArrangedExerciseView(plan: plan,
                                           incrementalOrderNumber: plan.arrangedExercises.count,
                                           completion: { _ in
                    viewModel.reloadArrangedExercises()
                })
                .presentationDetents([.fraction(0.7)])
                .presentationCornerRadius(16)
            }
        })
        .sheet(item: $exerciseToEdit) { exercise in
            EditArrangedExerciseView(arrangedExercise: exercise)
                .presentationDetents([.large])
                .presentationCornerRadius(16)
        }
        .sheet(isPresented: $isImporting, content: {
            PlanManagementView(isImporting: true) { plan in
                viewModel.importExercises(from: plan)
            }
        })
        
        // MARK: Observer
        .onChange(of: viewModel.currentPlan, { oldValue, newValue in
            viewModel.reloadArrangedExercises()
        })
        .onChange(of: viewModel.selectedDate) { oldValue, newValue in
            /// Reload current plan when date changed
            viewModel.currentPlan = viewModel.getPlan(by: newValue)
        }
        .onReceive(trainingSessionManager.timer) { _ in
            trainingSessionManager.handleTimerAction()
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(viewModel.selectedDate.format("MMMM")).foregroundStyle(Color.themeStyle.theme.accent)
                Text(viewModel.selectedDate.format("YYYY")).foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            }
            .font(.title.bold())
            
            Text(viewModel.selectedDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
            
            /// Week slider
            TabView(selection: $viewModel.currentWeekIndex) {
                ForEach(viewModel.weeks.indices, id: \.self) { index in
                    let week = viewModel.weeks[index]
                    WeekView(week).tag(index)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, -16)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .padding(.horizontal, 16)
        .background(Color.themeStyle.theme.background)
        .horizontalSpacing(.leading)
        .onChange(of: viewModel.currentWeekIndex, initial: false) { oldValue, newValue in
            /// Creating when it reaches first/last page
            if newValue == 0 || newValue == (viewModel.weeks.count - 1) {
                viewModel.createWeek = true
            }
        }
    }
    
    @ViewBuilder
    func WeekView(_ week: [Date.Weekday]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, viewModel.selectedDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, viewModel.selectedDate) {
                                Circle()
                                    .fill(Color.themeStyle.theme.accent)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            /// Indicator to Show, Which is Today's Date
                            if day.date.isToday {
                                Circle()
                                    .fill(Color.themeStyle.theme.accent)
                                    .frame(width: 5, height: 5)
                                    .veriticalSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                }
                .horizontalSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    /// Updating current date
                    viewModel.selectedDate = day.date
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear.preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        /// When the offset reachs 15 and if the createweek is toggled then simply generating next set of week
                        if value.rounded() == 16 && viewModel.createWeek {
                            viewModel.paginateWeek()
                            viewModel.createWeek = false
                        }
                    }
            }
        }
    }
    
    /// Schedule Exercises View
    @ViewBuilder
    func ArrangedExercisesView() -> some View {
        List {
            ForEach($viewModel.arrangedExercises, id: \.self) { $exercise in
                ArrangedExerciseCard(exercise: $exercise)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                viewModel.deleteExercise(exercise: exercise)
                            }
                        }) {
                            Image(systemName: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .swipeActions(edge: .leading) {
                        Button(action: {
                            /// Delete items
                            exercise.isCompleted.toggle()
                        }) {
                            Image(systemName: "checkmark")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(exercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.themeStyle.theme.secondaryTextColor)
                    }
                    .onTapGesture {
                        exerciseToEdit = exercise
                    }
            }
            .onMove(perform: { indexSet, newOffset in
                viewModel.arrangedExercises.move(fromOffsets: indexSet, toOffset: newOffset)
                
                /// Update all order number
                viewModel.updateOrderNumbers()
            })
            
            /// Bottom Placeholder
            VStack { }
            .frame(height: 140)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(Color.themeStyle.theme.background)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
    
    @ViewBuilder
    func PlaceholderView() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(LocalizationProvider.noExercises.nameKey)
                .font(.title2)
                .fontWeight(.bold)
            Text(LocalizationProvider.startAddingExerciseToPlan.nameKey)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Button(action: {
                isImporting.toggle()
            }) {
                Text(LocalizationProvider.importFromPlans.nameKey)
                    .background(Color.themeStyle.theme.accent)
                    .foregroundColor(Color.themeStyle.theme.white)
                    .horizontalSpacing(.center)
                    .frame(height: 44)
            }
            .background(Color.themeStyle.theme.accent)
            .cornerRadius(8)
            .padding(.horizontal, 64)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func TrainingSessionView() -> some View {
        VStack {
            if trainingSessionManager.startTime == nil {
                /// Show strat button
                TrainingSessionStartButton()
            }
            else {
                TrainingSessionRunningView()
                .frame(minHeight: 132)
            }
        }
        .horizontalSpacing(.center)
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top)
    }
    
    @ViewBuilder
    func TrainingSessionStartButton() -> some View {
        Button(action: {
            trainingSessionManager.configure(arrangedExercises: viewModel.arrangedExercises)
            trainingSessionManager.startTrainingSession()
        }) {
            Label("Start Training", systemImage: "flame.fill")
                .horizontalSpacing(.center)
                .font(.headline)
                .fontWeight(.semibold)
                .padding()
                .background(Color.themeStyle.theme.accent)
                .foregroundColor(Color.themeStyle.theme.white)
        }
    }
    
    @ViewBuilder
    func TrainingSessionRunningView() -> some View {
        VStack {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    if let startTime = trainingSessionManager.startTime {
                        ElapsedTimeView(startTime: startTime,
                                        restStartTime: trainingSessionManager.restStartTime,
                                        restIntervals: trainingSessionManager.restIntervals,
                                        currentIndexOfSet: trainingSessionManager.currentIndexOfSet,
                                        totalSetsCount: trainingSessionManager.currentExercise?.sets ?? 0)
                    }

                    ExerciseInfoView(isResting: trainingSessionManager.restStartTime != nil,
                                     exerciseName: trainingSessionManager.currentExercise?.exercise.name ?? "",
                                     weight: trainingSessionManager.currentExercise?.weight ?? 0,
                                     repetition: trainingSessionManager.currentExercise?.repetitions ?? 0)
                }
                
                ControlsView(isResting: trainingSessionManager.restStartTime != nil)
            }
            .padding(.vertical)
            .padding(.horizontal)
            
            StagesView(totalExerciseCount: trainingSessionManager.arrangedExercises.count,
                       currentStage: trainingSessionManager.currentStage)
        }
    }
    
    @ViewBuilder
    func ElapsedTimeView(startTime: Date, restStartTime: Date?, restIntervals: TimeInterval?, currentIndexOfSet: Int, totalSetsCount: Double) -> some View {
        HStack(spacing: 24) {
            Text("\(currentIndexOfSet)")
                .foregroundStyle(Color.themeStyle.theme.white.opacity(0.8))
                .font(.caption)
                .fontWeight(.semibold)
                .overlay {
                    ZStack {
                        Circle()
                            .stroke( // 1
                                Color.white.opacity(0.7),
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)
                        
                        Circle()
                            .trim(from: 0, to: Double(currentIndexOfSet) / totalSetsCount)
                            .stroke( // 1
                                Color.themeStyle.theme.accent,
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(-90))
                    }
                }
                .padding(.leading, 12)
            
            if let restStartTime = restStartTime, let restIntervals = restIntervals {
                Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restIntervals), countsDown: true)
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.blue)
                    .contentTransition(.numericText(countsDown: true))
            }
            else {
                Text(startTime, style: .timer)
                    .font(.title)
                    .fontWeight(.bold)
                    .tracking(1.4)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.themeStyle.theme.white.opacity(0.8))
                    .contentTransition(.numericText())
            }
        }
    }
    
    @ViewBuilder
    func SetsProgressView(indexOfSet: Int, totalSetsCount: Int) -> some View {
        ProgressView(value: CGFloat(indexOfSet) / CGFloat(totalSetsCount)) {
            Text("\(indexOfSet)")
        }
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeStyle.theme.accent))
    }
    
    @ViewBuilder
    func StagesView(totalExerciseCount: Int, currentStage: Int) -> some View {
        ProgressView(value: CGFloat(currentStage), total: CGFloat(totalExerciseCount))
            .progressViewStyle(.linear)
            .background(Color.white.opacity(0.7))
    }
    
    @ViewBuilder
    func ControlsView(isResting: Bool) -> some View {
        HStack(spacing: 16) {
            /// Stop Button
            Button(action: {
                trainingSessionManager.stopTrainingSession()
            }) {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
            .frame(width: 44, height: 44)
            .background(Color.white)
            .tint(Color.black.opacity(0.7))
            .cornerRadius(22)
            
            if isResting {
                Button(action: {
                    trainingSessionManager.endRest()
                }) {
                    Image(systemName: "chevron.forward.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .tint(Color.black.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(Color.white)
                .cornerRadius(22)
            }
            else {
                /// Done Button
                Button(action: {
                    if let exerciseID = trainingSessionManager.currentExercise?.id {
                        trainingSessionManager.completeCurrentSet(exerciseID: exerciseID.uuidString)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .frame(width: 44, height: 44)
                .background(Color.white)
                .tint(Color.black.opacity(0.7))
                .cornerRadius(22)
            }
        }
    }
    
    @ViewBuilder
    func ExerciseInfoView(isResting: Bool, exerciseName: String, weight: Double, repetition: Double) -> some View {
        VStack(spacing: 4) {
            if isResting {
                Text(LocalizationProvider.breakTimeTitle.nameKey)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(LocalizationProvider.breakTimeSubtitle.nameKey)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            }
            else {
                Text(exerciseName)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(Color.themeStyle.theme.accent.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(Int(weight))kg x \(Int(repetition))")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.subheadline)
                    .minimumScaleFactor(0.8)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
    }
}

#Preview("Main Screen") {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    let context = ModelContext(previewContainer.container)
    let viewModel = PivotMainViewModel(context: context)
    return PivotMainView(viewModel: viewModel,
                         trainingSessionManager: TrainingSessionManager.shared).modelContext(context)
    
}
