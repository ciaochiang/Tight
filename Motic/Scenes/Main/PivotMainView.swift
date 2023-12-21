//
//  PivotMainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

struct PivotMainView: View {
    @StateObject var viewModel: PivotMainViewModel
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.Weekday]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var scheduleExercise: Bool = false
    
    /// Animation  namespace
    @Namespace private var animation
    
    init(viewModel: PivotMainViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderView()
                        
            ScrollView(.vertical) {
                VStack {
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
        })
        .sheet(isPresented: $scheduleExercise, content: {
            ScheduleExerciseView()
                .presentationDetents([.height(300)])
                .presentationCornerRadius(30)

        })
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
    
    var startButton: some View {
        Button("Start") {
            // do something
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(Color.themeStyle.theme.green)
        .cornerRadius(8)
    }
    
    /// Schedule Exercises View
    @ViewBuilder
    func ScheduleExercisesView() -> some View {
        VStack(alignment: .leading, spacing: 36) {
            ForEach($viewModel.scheduledExercises) { $exercise in
                ScheduledExerciseCard(exercise: $exercise)
                    .background(alignment: .leading) {
                        if viewModel.scheduledExercises.last?.id != exercise.id {
                            Rectangle()
                                .frame(width: 1)
                                .offset(x: 8)
                                .padding(.bottom, -35)
                        }
                    }
            }
        }
        .padding([.vertical, .leading], 16)
        .padding(.top, 16)
    }
}

struct ScheduledExerciseCard: View {
    @Binding var exercise: ScheduledExercise
  
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.themeStyle.theme.accent)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)) , in: .circle)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.exericse.name)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Label(exercise.scheduledDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .padding(16)
            .horizontalSpacing(.leading)
            .background(Color.themeStyle.theme.background, in: .rect(topLeadingRadius: 16, bottomLeadingRadius: 16))
            .offset(y: -8)
        }
    }
}


#Preview {
    let viewModel = PivotMainViewModel()
    return PivotMainView(viewModel: viewModel)
}
