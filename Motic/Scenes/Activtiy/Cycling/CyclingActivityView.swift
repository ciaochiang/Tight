//
//  CyclingActivityView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/20.
//

import SwiftUI
import HealthKit
import Charts

struct CyclingActivityView: View {
  @StateObject var viewModel: CyclingActivityViewModel

  init(viewModel: CyclingActivityViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ZStack {
      ScrollView {
        VStack(alignment: .leading) {
          VStack(alignment: .leading, spacing: 16) {
            header
            durationCard
            totalDistance
            averageSpeedCard
            averageHeartRateCard
            Spacer()
          }
          .padding()
          .background(Color.themeStyle.theme.background)
        }
        Spacer()
      }
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
  var header: some View {
    HStack {
      Text(viewModel.workoutType.description)
        .font(.largeTitle)
      Spacer()
    }
  }
  
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
      
      if viewModel.distanceSamples?.isEmpty != true {
        distanceChart
          .frame(maxHeight: 160)
      }
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var averageSpeedCard: some View {
    VStack {
      HStack {
        Text("Avg. Speed / hr")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text("\(viewModel.healthStoreManager.formattedTotalDistance(meters: viewModel.avgSpeedPerHour))/hr")
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
        Text("\(String(format: "%.0f", viewModel.avgHeartRate)) bpm")
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    
      if viewModel.heartRateSamples.isEmpty != true {
        heartRateChart
          .frame(maxHeight: 160)
      }
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var distanceChart: some View {
    Chart(viewModel.distanceSamples ?? []) {
      LineMark(
        x: .value("Time", $0.startDate),
        y: .value("Distance", $0.value)
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
  }
  
  var heartRateChart: some View {
    Chart(viewModel.heartRateSamples) {
      LineMark(
        x: .value("Time", $0.startDate),
        y: .value("Heart Rate", $0.value)
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
  }
}
