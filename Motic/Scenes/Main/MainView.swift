//
//  MainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import HealthKit

struct MainView: View {
  @StateObject var viewModel: MainViewModel = MainViewModel(
    dependency: MainViewModelDependencyImp(logger: Logger(configuration: AppConfiguration.loggerConfig)))
  
  var body: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          topSeciton
          currentActivitySection
          sumamrySection
          activitiesSeciton
          Spacer()
        }
        .padding(24)
      }
    }
    .background(
      Color.themeStyle.theme.background.ignoresSafeArea()
    )
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

// MARK: Sections
extension MainView {
  var topSeciton: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text("Welcome Back")
          .font(.subheadline)
          .foregroundColor(.themeStyle.theme.primary)
        Text("Ciao Chiang")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.themeStyle.theme.primary)
      }

      Spacer()
      Image(systemName: "person")
        .frame(width: 60, height: 60)
        .foregroundColor(.black)
        .background(Color.white)
        .cornerRadius(30)
    }
  }
  
  var currentActivitySection: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Working Out...")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.themeStyle.theme.white)
        Text("Indoor Cycling")
          .font(.subheadline)
          .fontWeight(.regular)
          .foregroundColor(.themeStyle.theme.accent)
      }
      Spacer()
      VStack(alignment: .center) {
        Text("1:30:20")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.themeStyle.theme.accent)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.black)
    .cornerRadius(16)
  }
  
  var sumamrySection: some View {
    VStack(spacing: 8) {
      MainViewSectionHeader(sectionTitle: "Summary")
      HStack(spacing: 16) {
        heartRateWidgetCard
        zoneWidgetCard
      }
    }
  }
  
  var activitiesSeciton: some View {
    VStack(spacing: 8) {
      MainViewSectionHeader(sectionTitle: "Activites")
      
      VStack(spacing: 16) {
        ForEach(viewModel.healthStoreManager.activities, id: \.self) { activity in
          MainViewActivityCard(activity: activity)
        }
      }
    }
  }
  
  var footerSection: some View {
    HStack {
      Button {
        
      } label: {
        Text("Go")
          .font(.headline)
      }
      .frame(height: 60)
      .frame(maxWidth: .infinity)
      .foregroundColor(.themeStyle.theme.white)
      .background(Color.orange)
      .cornerRadius(8)
    }
  }
}

struct MainViewSectionHeader: View {
  let sectionTitle: String
  
  var body: some View {
    HStack {
      Text(sectionTitle)
        .font(.headline)
        .foregroundColor(.themeStyle.theme.primary)
      Spacer()
    }
    .frame(height: 60)
    .frame(maxWidth: .infinity)
  }
}

// MARK: Widget Card
extension MainView {
  // MARK: Summary Seciton
  var heartRateWidgetCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "heart.fill")
          .resizable()
          .foregroundColor(viewModel.isHeartRateAuthorized
                           ? .themeStyle.theme.red
                           : .themeStyle.theme.secondaryTextColor)
          .frame(width: 12, height: 12)
          .scaledToFit()
        Text("Heart Rate")
          .foregroundColor(viewModel.isHeartRateAuthorized
                           ? .themeStyle.theme.primary
                           : .themeStyle.theme.secondaryTextColor)
          .font(.caption)
          .fontWeight(.semibold)
      }
      .padding(16)
      HStack(spacing: 8) {
        Text(viewModel.isHeartRateAuthorized
             ? "\(Int(viewModel.healthStoreManager.latestHeartRate.value))"
             : "0")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(viewModel.isHeartRateAuthorized
                           ? .themeStyle.theme.red
                           : .themeStyle.theme.secondaryTextColor)
          .multilineTextAlignment(.center)
        Text("BPM")
          .foregroundColor(.primary)
          .font(.caption2)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
    .onTapGesture {
      if viewModel.isHeartRateAuthorized {
        // lead user to setting page
        if let url = URL(string: "x-apple-health://") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
      }
    }
  }
  
  var zoneWidgetCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "flame.fill")
          .resizable()
          .foregroundColor(.themeStyle.theme.red)
          .frame(width: 12, height: 12)
          .scaledToFit()
        Text("Zone")
          .foregroundColor(.themeStyle.theme.primary)
          .font(.caption)
          .fontWeight(.semibold)
      }
      .padding(16)
      HStack(spacing: 8) {
        Text("\(viewModel.healthStoreManager.currentZone?.zoneName ?? "Zone 1")")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.themeStyle.theme.red)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
}

struct MainViewActivityCard: View {
//  @State var activtiy: HKWorkout
//
//  init(activity: HKWorkout) {
//    self.activtiy = activity
//  }
  @State var activity: HKWorkout
  @State var activityType: String
  @State var totalEnergyBurned: Double
  
  init(activity: HKWorkout) {
    self.activity = activity
    activityType = ActivityType(activityType: activity.workoutActivityType).description
    
    if let totalEnergyBurned = activity.totalEnergyBurned {
      // Get the value in kilocalories (kcal)
      let totalEnergyBurnedInKcal = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
      self.totalEnergyBurned = totalEnergyBurnedInKcal
    } else {
        // The workout did not provide energy burned data
      self.totalEnergyBurned = 0
    }
  }
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: "figure.indoor.cycle")
        .resizable()
        .scaledToFit()
        .foregroundColor(Color(UIColor.systemPink))
        .frame(maxWidth: 16)
      VStack(alignment: .leading, spacing: 4) {
        Text(activityType)
          .font(.caption)
          .foregroundColor(.secondary)
        Text("\(totalEnergyBurned) Kcal")
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        Text("\(Int(activity.duration / 60)) mins")
          .fontWeight(.semibold)
          .foregroundColor(.primary)
      }
      
      Spacer()

    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
}
