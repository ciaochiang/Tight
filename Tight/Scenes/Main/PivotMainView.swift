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
            
            ///  Scheduled exercises
            if viewModel.currentPlan?.arrangedExercises.isEmpty == true {
                PlaceholderView()
                    .veriticalSpacing(.center)
                    .horizontalSpacing(.center)
                    .offset(y: -32)
            }
            else {
                ZStack {
                    ArrangedExercisesView()
                    VStack {
                        Spacer()
                        TrainingSessionView()
                            .padding(.bottom)
                    }
                }
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
            .offset(y: -120)
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
                TrainingSessionRunningView(startTime: $trainingSessionManager.startTime,
                                           restStartTime: $trainingSessionManager.restStartTime, 
                                           restIntervals: $trainingSessionManager.restIntervals,
                                           currentIndexOfSet: $trainingSessionManager.currentIndexOfSet,
                                           currentSetsProgress: $trainingSessionManager.currentSetsProgress,
                                           currentExercise: $trainingSessionManager.currentExercise,
                                           totalExerciseCount: $trainingSessionManager.totalExerciseCount,
                                           currentStage: $trainingSessionManager.currentStage,
                                           onStopButtonTapped: {
                    trainingSessionManager.stopTrainingSession()
                    
                },
                                           onCompleteButtonTapped: { exerciseID in
                    trainingSessionManager.completeCurrentSet(exerciseID: exerciseID)
                },
                                           onSkipButtonTapped: {
                    trainingSessionManager.endRest()
                })
            }
        }
        .horizontalSpacing(.center)
        .background(Color.black.opacity(0.7))
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
        .frame(height: 44)
    }
}

#Preview("Main Screen") {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    let context = ModelContext(previewContainer.container)
    let viewModel = PivotMainViewModel(context: context)
    return PivotMainView(viewModel: viewModel,
                         trainingSessionManager: TrainingSessionManager.shared).modelContext(context)
    
}
