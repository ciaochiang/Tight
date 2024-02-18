//
//  MainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

struct MainView: View {
    @Environment(\.modelContext) var context
    @StateObject var viewModel: MainViewModel
    @EnvironmentObject var trainingSessionManager: TrainingSessionManager
    @State private var isArrangingExercise: Bool = false
    @State private var isImporting: Bool = false
    @State private var exerciseToEdit: ArrangedExercise?
    @State private var showTrainingSessionRunningView: Bool = false
    @State private var isPresentingConfirm: Bool = false
    @State private var isItemEditable: Bool = true
    @State private var isDataChanged: Bool = false
    @State private var isTrainingExtenedViewPresented: Bool = false
        
    /// Animation  namespace
    @Namespace private var animation
    
    init(viewModel: MainViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
            
            ///  Scheduled exercises
            if viewModel.currentPlan.alleExercises().isEmpty {
                PlaceholderView()
                    .veriticalSpacing(.center)
                    .horizontalSpacing(.center)
                    .offset(y: -32)
            }
            else {
                ExerciseListView()
            }
            
            ControlPanelView()
                /// This fix child view has parent view's shadow
                /// Reference: https://stackoverflow.com/questions/58667109/subview-have-parents-shadow-even-with-a-background
                .compositingGroup()
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: -1)
        }
        .background(Color.themeStyle.theme.background)
        .onAppear(perform: {
            trainingSessionManager.configure(modelContext: viewModel.context)
            
            if viewModel.weeks.isEmpty {
                viewModel.loadWeeks()
            }
            
            let screenName = String(describing: MainView.self)
            AnalyticsHelper.logScreen(screenName: screenName, screenClass: screenName)
        })
        
        // MARK: Bottom Sheet
        .sheet(isPresented: $isArrangingExercise, content: {
            let count = viewModel.currentPlan.alleExercises().count
            CreateArrangedExerciseView(plan: viewModel.currentPlan,
                                       incrementalOrderNumber: count,
                                       completion: { _ in
            })
            .presentationDetents([.large])
            .presentationCornerRadius(16)
        })
        .sheet(item: $exerciseToEdit) { exercise in
            EditArrangedExerciseView(arrangedExercise: exercise, isDataChanged: $isDataChanged)
                .presentationDetents([.large])
                .presentationCornerRadius(16)
        }
        .sheet(isPresented: $isImporting, content: {
            PlanManagementView(isImporting: true) { plan in
                viewModel.importExercises(from: plan)
            }
        })
        .fullScreenCover(isPresented: $isTrainingExtenedViewPresented, content: {
            TrainingSessionExtendedView(content: $trainingSessionManager.content)
        })
        .onChange(of: viewModel.selectedDate) { oldValue, newValue in
            /// Reload current plan when date changed
            viewModel.onSelectedDate(newValue)
            
            /// If the `selectedDay` is `today` and `trainingSessionManager` is `running`
            /// then `disable` item editibility
            let isSessionRunning = newValue.isToday && trainingSessionManager.isRunning
            isItemEditable = !isSessionRunning
        }
        .onChange(of: trainingSessionManager.isRunning, { oldValue, newValue in
            /// If the `selectedDay` is `today` and `trainingSessionManager` is `running`
            /// then `disable` item editibility
            let isSessionRunning = viewModel.selectedDate.isToday && newValue == true
            isItemEditable = !isSessionRunning
        })
        .onReceive(trainingSessionManager.timer) { _ in
            trainingSessionManager.handleTimerAction()
        }
        .onChange(of: trainingSessionManager.content.startTime) { oldValue, newValue in
            withAnimation {
                showTrainingSessionRunningView = newValue != nil
            }
        }
        .onChange(of: trainingSessionManager.content.state, { oldValue, newValue in
            if newValue == .training || newValue == .resting {
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        })
        .onChange(of: viewModel.weeks, { oldValue, newValue in
            viewModel.loadPlans(weeks: newValue)
        })
        .environmentObject(trainingSessionManager)
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
                            
                            if let plan = viewModel.plansOfWeeks.first(where: { $0.startDate == day.date }),
                                plan.alleExercises().contains(where: { $0.isCompleted }) {
                                Circle()
                                    .stroke(Color.themeStyle.theme.accent, lineWidth: 2)
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
    func ExerciseListView() -> some View {
        List {
            /// Daily Summary Section
            if viewModel.showDailySummary {
                Section {
                    TrainingSessionDailyReportView(plan: viewModel.currentPlan, isDataChanged: $isDataChanged)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text(LocalizationProvider.sectionDailySummary.nameKey)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                        .horizontalSpacing(.leading)
                        .padding(.leading)
                }
                .background(Color.themeStyle.theme.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            
            /// Arranged Exericses Section
            Section {
                let exercises = viewModel.currentPlan.alleExercises()
                ForEach(exercises) { exercise in
                    MainViewExerciseCardView(exercise: exercise, isItemEditable: $isItemEditable)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .swipeActions(edge: .trailing) {
                            if isItemEditable {
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
                        }
                        .swipeActions(edge: .leading) {
                            if isItemEditable {
                                Button(action: {
                                    /// Delete items
                                    exercise.isCompleted.toggle()
                                    isDataChanged.toggle()
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                }
                                .tint(exercise.isCompleted ? Color.themeStyle.theme.secondaryAccent : Color.themeStyle.theme.secondaryBackground)
                            }
                        }
                        .onTapGesture {
                            exerciseToEdit = exercise
                        }
                        .allowsHitTesting(isItemEditable)
                }
                .onMove(perform: { indexSet, newOffset in
                    /// Update all order number
                    viewModel.updateOrderNumbers(from: indexSet, to: newOffset)
                })
            } header: {
                Text(LocalizationProvider.sectionExercises.nameKey)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
                    .padding(.leading)
                    .horizontalSpacing(.leading)
            }
            .background(Color.themeStyle.theme.background)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .scrollIndicators(.hidden)
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
                Text(LocalizationProvider.addFromPlan.nameKey)
                    .fontWeight(.semibold)
                    .background(Color.themeStyle.theme.accent)
                    .foregroundColor(Color.themeStyle.theme.white)
                    .horizontalSpacing(.center)
                    .frame(height: 44)
            }
            .background(Color.themeStyle.theme.accent)
            .cornerRadius(8)
            .padding(.horizontal, 88)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func ControlPanelView() -> some View {
        if !showTrainingSessionRunningView {
            /// Show strat button
            HStack(spacing: 4) {
                /// Only dislay trainnin session button when the selected day is today.
                if viewModel.selectedDate.isToday && viewModel.currentPlan.alleExercises().isEmpty == false {
                    TrainingSessionStartButton()
                    Rectangle().fill(Color.themeStyle.theme.white.opacity(0.3)).frame(width: 1, height: 32)
                }

                
                Button(action: {
                    isArrangingExercise.toggle()
                }) {
                    if viewModel.currentPlan.alleExercises().isEmpty || !viewModel.selectedDate.isToday {
                        Label(LocalizationProvider.addExercise.nameKey, systemImage: "plus")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 20)
                            .foregroundColor(Color.themeStyle.theme.white)
                            .contentShape(Rectangle())
                            .horizontalSpacing(.center)
                    }
                    else {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .contentShape(Rectangle())
                            .horizontalSpacing(.center)
                            .frame(height: 44)
                    }
                }
                .frame(maxWidth: viewModel.currentPlan.alleExercises().isEmpty || !viewModel.selectedDate.isToday ? .infinity : 80, alignment: .center)
            }
            .transition(.move(edge: .bottom))
            .background(Color.themeStyle.theme.accent)
        }
        else {
            TrainingSessionCollapsedView(content: $trainingSessionManager.content)
                .onTapGesture {
                    isTrainingExtenedViewPresented.toggle()
                }
                .transition(.move(edge: .bottom))
        }
    }
    
    @ViewBuilder
    func TrainingSessionStartButton() -> some View {
        Button(action: {
            /// If user hasn't training yet, then start the training directly
            if viewModel.currentPlan.trainingLog == nil {
                let arrangedExercises = viewModel.currentPlan.alleExercises()
                trainingSessionManager.startSession(plan: viewModel.currentPlan,
                                                    arrangedExercises: arrangedExercises)
            } else {
                /// Display confirmation dialog before `restart training`
                isPresentingConfirm.toggle()
            }
        }) {
            Label(viewModel.currentPlan.trainingLog != nil
                  ? LocalizationProvider.restartTraining.nameKey
                  : LocalizationProvider.startTraining.nameKey, systemImage: "flame.fill")
                .horizontalSpacing(.center)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.vertical, 20)
                .foregroundColor(Color.themeStyle.theme.white)
        }
        .contentShape(Rectangle())
        .confirmationDialog("Are your sure?", isPresented: $isPresentingConfirm) {
            Button(LocalizationProvider.confirmRestartTraining.nameKey, role: .destructive) {
                if let exercises = viewModel.currentPlan.arrangedExercises {
                    trainingSessionManager.startSession(plan: viewModel.currentPlan,
                                                                arrangedExercises: exercises)
                }
            }
            .fontWeight(.semibold)
        } message: {
            Text(LocalizationProvider.confirmRestartTrainingDescription.nameKey)
        }
    }
}

#Preview("Main Screen") {
    let previewContainer = PreviewContainer([ArrangedExercise.self, Plan.self])
    let context = ModelContext(previewContainer.container)
    let viewModel = MainViewModel(context: context, currentDate: .init())
    return MainView(viewModel: viewModel)
        .modelContext(context)
        .environmentObject(TrainingSessionManager())
}
