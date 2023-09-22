//
//  CyclingActivityView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/20.
//

import SwiftUI
import HealthKit
import Charts

struct MonthlyHoursOfSunshine: Identifiable {
  let id: String = UUID().uuidString
    var date: Date
    var hoursOfSunshine: Double


    init(month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
    }
}

struct CyclingActivityView: View {
  @StateObject var viewModel: CyclingActivityViewModel

  init(viewModel: CyclingActivityViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var data: [MonthlyHoursOfSunshine] = [
    MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
    MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
    MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 62)
  ]


    var body: some View {
      ZStack {
        VStack(alignment: .leading) {
 
          VStack(alignment: .leading, spacing: 24) {
            HStack {
              Text(viewModel.workoutType.description)
                .font(.largeTitle)
              Spacer()
            }
            
            durationCard
            totalDistance
            averageSpeedCard
            averageHeartRateCard
            
            Chart(data) {
                    LineMark(
                        x: .value("Month", $0.date),
                        y: .value("Hours of Sunshine", $0.hoursOfSunshine)
                    )
                }
            .chartXAxis {
              AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
              }
            }
            .chartYAxis {
              AxisMarks(position: .leading, values: .automatic) { _ in
                AxisValueLabel()	
              }
            }
            .padding()
            .frame(height: 300)
            
            Spacer()
          }
          .padding()
          .background(Color.themeStyle.theme.background)
        }
        Spacer()
      }
      .background(
        Color.themeStyle.theme.background.ignoresSafeArea()
      )
    }
  
 
}

struct CyclingActivityView_Previews: PreviewProvider {
    static var previews: some View {
      let dependency = CyclingActivityViewModelDependencyImp(
        logger: Logger(configuration: AppConfiguration.loggerConfig))
      let viewModel = CyclingActivityViewModel(dependency: dependency,
                                               healthStoreManager: Mocks.mockHealthStoreManager,
                                               workout: Mocks.mockWorkout)
      CyclingActivityView(viewModel: viewModel)
    }
}

// MARK: Components
extension CyclingActivityView {
  var durationCard: some View {
    VStack {
      HStack {
        Text("Duration")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text(viewModel.getFormattedDuration(duration: viewModel.duraiton))
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var totalDistance: some View {
    VStack {
      HStack {
        Text("Total Distance")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text(viewModel.healthStoreManager.formattedTotalDistance(meters: viewModel.totalDistanceMeters))
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var averageSpeedCard: some View {
    VStack {
      HStack {
        Text("Avg. Speed / Km")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text("10:40 / km")
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var averageHeartRateCard: some View {
    VStack {
      HStack {
        Text("Avg. Heart Rate")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text("154")
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
}
