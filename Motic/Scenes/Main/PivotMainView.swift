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
                }
                .horizontalSpacing(.center)
                .veriticalSpacing(.center)
            }
            .scrollIndicators(.hidden)
        }
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
    
    var scheduledExercises: some View {
        VStack {
            ForEach(viewModel.scheduledExercises) { exercise in
                ScheduledExerciseCard(exercise: exercise)
            }
            Spacer(minLength: 100)
        }
    }
}

struct ScheduledExerciseCard: View {
    var exerise: ScheduledExerciseItem

    init(exercise: ScheduledExerciseItem) {
        self.exerise = exercise
    }
  
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerise.name)
                    .font(.headline)
                    .foregroundColor(.themeStyle.theme.secondaryTextColor)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.themeStyle.theme.secondaryBackground)
        .cornerRadius(8)
    }
}


#Preview {
    let viewModel = PivotMainViewModel()
    return PivotMainView(viewModel: viewModel)
}
