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
      let dependency = CyclingActivityViewModelDependencyImp(logger: Mocks.logger)
      let viewModel = CyclingActivityViewModel(dependency: dependency,
                                               healthStoreManager: Mocks.mockHealthStoreManager,
                                               activity: Mocks.mockActivity)
      CyclingActivityView(viewModel: viewModel)
                
        
        // For Component Preview
        /* DistanceLineChart(data: Mocks.chartDataSet)
            .previewLayout(.sizeThatFits)
            .frame(height: 160) */
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
        Text("Heart Rate")
          .font(.headline)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Text("\(String(format: "%.0f", viewModel.avgHeartRate)) bpm")
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
      .padding(16)
    
      if viewModel.heartRateSamples.isEmpty != true {
          HeartRateLineChart(data: viewModel.heartRateSamples)
              .frame(maxHeight: 160)
      }
      
      if let zones = viewModel.zones {
        ZoneDurationSection(zones: zones)
      }
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
  
  var distanceChart: some View {
    Chart(viewModel.distanceSamples ?? []) {
      
        LineMark(
            x: .value("Time", $0.date, unit: .second),
            y: .value("Distance", $0.value)
        )
        .foregroundStyle(Color.blue.gradient)

        AreaMark(x: .value("Time", $0.date), yStart: .value("Min", 0), yEnd: .value("Max", $0.value))
            .foregroundStyle(LinearGradient(colors: [Color.blue.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
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

struct DistanceLineChart: View {
    let data: [ChartData<Double>]
    
    var body: some View {
        Chart(data) {
          LineMark(
            x: .value("Time", $0.date, unit: .second),
            y: .value("Distance", $0.value)
          )
          .foregroundStyle(Color.blue.gradient)

            AreaMark(x: .value("Time", $0.date), yStart: .value("Min", 0), yEnd: .value("Max", $0.value))
                .foregroundStyle(LinearGradient(colors: [Color.blue.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
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

struct HeartRateLineChart: View {
    let data: [ChartData<Double>]
    
    var body: some View {
        Chart(data) {
          LineMark(
            x: .value("Time", $0.date, unit: .second),
            y: .value("Heart Rate", $0.value)
          )
          .foregroundStyle(Color.pink.gradient)
            AreaMark(x: .value("Time", $0.date), yStart: .value("Min", 0), yEnd: .value("Max", $0.value))
                .foregroundStyle(LinearGradient(colors: [Color.pink.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
        }
        .chartXAxis {
    //        AxisMarks(values: viewModel.heartRateSamples.map { $0.startDate }) { value in
    //            if let date = value.as(Date.self) {
    //                let hour = Calendar.current.component(.hour, from: date)
    //                switch hour {
    //                case 0, 12:
    //                    AxisValueLabel(format: .dateTime.hour())
    //                default:
    //                    AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
    //                }
    //            }
    //        }
        }
        .chartYAxis {
          AxisMarks(position: .leading, values: .automatic) { _ in
            AxisValueLabel()
          }
        }
        .padding()
    }
}

struct ZoneDurationSection: View {
  var zones: [Zone]
  
  init(zones: [Zone]) {
    self.zones = zones
  }
  
  var body: some View {
    HStack(spacing: 24) {
      ForEach(zones) { zone in
        VStack(spacing: 4) {
          Text(zone.type.aliasName)
            .font(.caption2)
            .foregroundColor(.themeStyle.theme.secondaryTextColor)
          Text("\(zone.duration.formatTimeInterval)")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.themeStyle.theme.secondaryTextColor)
        }
      }
    }
    .padding(16)
  }
}
