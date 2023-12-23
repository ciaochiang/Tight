//
//  PivotMainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI
import SwiftData

struct PivotMainView: View {
    @Environment(\.modelContext) var context
    @StateObject var viewModel: PivotMainViewModel
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.Weekday]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var scheduleExercise: Bool = false
    @State private var exerciseToEdit: ScheduledExercise?
        
    /// Animation  namespace
    @Namespace private var animation
    
    init(viewModel: PivotMainViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderView()
                        
            ScrollView(.vertical) {
                LazyVStack {
                    ///  Scheduled exercises
                    ScheduleExercisesView()
                }
                .horizontalSpacing(.center)
                .veriticalSpacing(.center)
                
                Spacer(minLength: 48)
            }
            .scrollIndicators(.hidden)
        }
        .veriticalSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                scheduleExercise.toggle()
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

            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }
                
                weekSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
            
            /// Load Scheduled Exercises
            loadScheduledExercises(currentDate: currentDate)
        })
        .sheet(isPresented: $scheduleExercise, content: {
            ScheduleExerciseView(completion: {
                /// Refetch schedule  exercises
                loadScheduledExercises(currentDate: currentDate)
            })
                .presentationDetents([.height(400)])
                .presentationCornerRadius(30)

        })
        .sheet(item: $exerciseToEdit) { exercise in
            EditScheduledExerciseView(scheduledExercise: exercise)
                .presentationDetents([.height(300)])
                .presentationCornerRadius(30)
        }
        .onChange(of: currentDate) { oldValue, newValue in
            /// Fetch scheduled exercise when date changed
            loadScheduledExercises(currentDate: newValue)
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
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
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
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear.preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        /// When the offset reachs 15 and if the createweek is toggled then simply generating next set of week
                        if value.rounded() == 16 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
    
    func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                /// Inserting new week at 0th indx and removing last array item
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                /// Inserting new week at last indx and removing last array item
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(currentDate.format("MMMM")).foregroundStyle(Color.themeStyle.theme.accent)
                Text(currentDate.format("YYYY")).foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            }
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
            
            /// Week slider
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week).tag(index)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, -16)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .padding(.horizontal, 16)
        .background(.white)
        .horizontalSpacing(.leading)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            /// Creating when it reaches first/last page
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }
    
    /// Schedule Exercises View
    @ViewBuilder
    func ScheduleExercisesView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach($viewModel.scheduledExercises) { $exercise in
                ScheduledExerciseCard(exercise: $exercise, onTap: { exercise in
                    /// Edit
                    self.exerciseToEdit = exercise
                }, onLongPress: { exercise in
                    /// Delete dialog
                }, onDelete: { exercise in
                    /// Delete items
                    ///
                    withAnimation(.easeIn) {
                        context.delete(exercise)
                        
                        /// Reload
                        loadScheduledExercises(currentDate: currentDate)
                    }

                })
//                    .background(alignment: .leading) {
//                        Rectangle()
//                            .foregroundStyle(Color.themeStyle.theme.accent)
//                            .frame(width: 2)
//                    }
            }
        }
        .padding(.top, 16)
    }
    
    /// Load scheduled exercises from Swift Data
    private func loadScheduledExercises(currentDate: Date) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: currentDate)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        let fetchDescriptor = FetchDescriptor<ScheduledExercise>(predicate: #Predicate<ScheduledExercise> { $0.scheduledDate > startDate && $0.scheduledDate < endDate })
        
        do {
            viewModel.scheduledExercises = try context.fetch(fetchDescriptor)
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

struct ScheduledExerciseCard: View {
    @Binding var exercise: ScheduledExercise
    @State var offset: Double = 0
    @State var isSwiped: Bool = false
    
    /// Edit Action
    let onTap: (ScheduledExercise) -> Void
    
    /// Delete action
    let onLongPress: (ScheduledExercise) -> Void
    
    let onDelete: (ScheduledExercise) -> Void
  
    var body: some View {
        ZStack {
            /// Swipe view
            LinearGradient(gradient: .init(colors: [Color.themeStyle.theme.accent, Color.red]),
                           startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/,
                           endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
            
            /// Delete button
            HStack {
                Spacer()
                Button(action: {
                    onDelete(exercise)
                }) {
                    Image(systemName: "trash")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.white)
                        .frame(width: 90, height: 36)
                        .veriticalSpacing(.center)
                }
            }
            
            
            /// Content
            HStack(alignment: .center) {
                Rectangle()
                    .foregroundStyle(Color.themeStyle.theme.accent)
                    .frame(width: 1)

                ExerciseView()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .offset(x: offset)
            .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
        }
    }
    
    @ViewBuilder
    func ExerciseView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseNameView()
            ExerciseDetailsView().horizontalSpacing(.leading)
        }
        .horizontalSpacing(.leading)
        .padding()
        .background(Color.themeStyle.theme.background)
        .gesture(LongPressGesture(minimumDuration: 0.3).onEnded({ _ in
            onLongPress(exercise)
        }))
        .highPriorityGesture(TapGesture().onEnded({ _ in
            onTap(exercise)
        }))
    }
    
    @ViewBuilder
    func ExerciseDetailsView() -> some View {
        HStack(alignment: .center, spacing: 16) {
            Label("\(Int(exercise.repetitions))", systemImage: "repeat")
                .font(.caption)
                .foregroundColor(.black)
            
            Label("\(Int(exercise.sets))", systemImage: "square.stack.3d.down.right")
                .font(.caption)
                .foregroundColor(.black)
            
            Label(exercise.restIntevals.formatIntervalToMinutesSeconds, systemImage: "clock")
                .font(.caption)
                .foregroundColor(.black)
            
        }
    }
    
    @ViewBuilder
    func ExerciseNameView() -> some View {
        Text(exercise.exericse.name)
            .fontWeight(.semibold)
            .foregroundStyle(.black)
    }
    
    func onChanged(value: DragGesture.Value) {
        if value.translation.width < 0 {
            if isSwiped {
                offset = value.translation.width - 90
            }
            else {
                offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeInOut) {
            if value.translation.width < 0 {
                
                /// Checking
                if -value.translation.width > UIScreen.main.bounds.width / 2 {
                    offset = -1000
                    onDelete(exercise)
                }
                else if -offset > 50 {
                    isSwiped = true
                    offset = -90
                }
                else {
                    isSwiped = false
                    offset = 0
                }
            }
            else {
                isSwiped = false
                offset = 0
            }
        }
        
    }
}


#Preview("Main Screen") {
    let viewModel = PivotMainViewModel()
    let previewContainer = PreviewContainer([ScheduledExercise.self])
    return PivotMainView(viewModel: viewModel).modelContainer(previewContainer.container)
    
}
