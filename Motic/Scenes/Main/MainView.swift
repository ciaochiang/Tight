//
//  MainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import HealthKit
import Charts

struct MainView: View {
  @StateObject var viewModel: MainViewModel
  @StateObject var preferenceManager: PreferenceManager
  @State var isPresented: Bool = false
  @State var isActivityViewPresented: Bool = false
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _preferenceManager = StateObject(wrappedValue: viewModel.dependency.preferenceManager)
  }
  
  var body: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          topSeciton
          currentActivitySection
          sumamrySection
          activitiesSeciton
          Spacer()
        }
        .padding()
      }
    }
    .background(
      Color.themeStyle.theme.background.ignoresSafeArea()
    )
    .preferredColorScheme(preferenceManager.colorScheme)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                logger: Mocks.logger)
    let viewModel = MainViewModel(dependency: dependency)
    MainView(viewModel: viewModel)
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
        Text(viewModel.user?.firstName ?? "")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.themeStyle.theme.primary)
      }

      Spacer()
      Button(action: {
        isPresented = true
      }) {
        Image(systemName: "person")
          .frame(width: 60, height: 60)
          .foregroundColor(.black)
          .background(Color.white)
          .cornerRadius(30)
      }
      .sheet(isPresented: $isPresented) {
        let logger = Logger(configuration: AppConfiguration.loggerConfig)
        let dependency = ProfileViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                       logger: logger,
                                                       currentUser: AccountManager.shared.currentUser)
        let viewModel = ProfileViewModel(dependency: dependency)
        ProfileView(viewModel: viewModel)
          .presentationDetents([.medium])
      }
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
        ForEach(viewModel.activities, id: \.self) { workout in
          Button {
            viewModel.selectedWorkout = workout
            isActivityViewPresented.toggle()
          } label: {
            MainViewActivityCard(activity: workout)
          }
        }
      }
      .sheet(isPresented: $isActivityViewPresented) {
        if let selectedWorkout = viewModel.selectedWorkout  {
          let dependency = CyclingActivityViewModelDependencyImp(logger: viewModel.dependency.logger)
          let viewModel = CyclingActivityViewModel(dependency: dependency,
                                                   healthStoreManager: viewModel.healthStoreManager,
                                                   workout: selectedWorkout)
          CyclingActivityView(viewModel: viewModel).presentationDetents([.large])
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
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(.themeStyle.theme.primary)
          Spacer()
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom)
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
        Text("\(viewModel.healthStoreManager.currentZone?.name ?? "Zone 1")")
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
  @State var activity: HKWorkout
  @State var activityType: WorkoutActivityType
  @State var formmatedStartDate: String
  @State var totalEnergyBurned: Double
  
  init(activity: HKWorkout) {
    self.activity = activity
    activityType = WorkoutActivityType(activityType: activity.workoutActivityType)
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current // Use the current timezone
    dateFormatter.dateFormat = "yyyy/MM/dd"
    formmatedStartDate = dateFormatter.string(from: activity.startDate)
    
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
      Image(systemName: activityType.systemIconName)
        .resizable()
        .scaledToFit()
        .foregroundColor(Color(UIColor.systemPink))
        .frame(maxWidth: 24)
        .frame(maxHeight: 24)
      VStack(alignment: .leading, spacing: 4) {
        Text(activityType.description)
          .font(.caption)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
        Text("\(String(format: "%.1f", totalEnergyBurned)) Kcal")
          .fontWeight(.semibold)
          .foregroundColor(.themeStyle.theme.primary)
        Text("\(Int(activity.duration / 60)) mins")
          .fontWeight(.semibold)
          .foregroundColor(.themeStyle.theme.primary)
      }
      
      Spacer()
      VStack {
        Text(formmatedStartDate)
          .font(.caption)
          .foregroundColor(.themeStyle.theme.secondaryTextColor)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.secondaryBackground)
    .cornerRadius(16)
  }
}
