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
    @StateObject var activitySessionManager: ActivitySessionManager
    @State var isProfileViewPresented: Bool = false
    @State var isActivityViewPresented: Bool = false
  
    init(viewModel: MainViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _preferenceManager = StateObject(wrappedValue: viewModel.dependency.preferenceManager)
        _activitySessionManager = StateObject(wrappedValue: ActivitySessionManager.shared)
    }
  
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        topSeciton
                        
                        if activitySessionManager.isRecording {
                            currentActivitySection
                        }
                        
                        weeklySummarySection
                        activitiesSeciton
                        Spacer()
                    }
                    .padding()
                }
                .background(Color.themeStyle.theme.background)
            }
            .sheet(isPresented: $isProfileViewPresented) {
                let dependency = ProfileViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                               logger: viewModel.dependency.logger,
                                                               currentUser: AccountManager.shared.currentUser)
                let viewModel = ProfileViewModel(dependency: dependency)
                ProfileView(viewModel: viewModel)
                  .presentationDetents([.medium])
            }
        }
        .preferredColorScheme(preferenceManager.colorScheme)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let dependency = MainViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                    activtiySessionManager: Mocks.activitySessionManager,
                                                    logger: Mocks.logger)
        let viewModel = MainViewModel(dependency: dependency, isRecordViewPresented: .constant(false))
        MainView(viewModel: viewModel)
    }
}

// MARK: Sections
extension MainView {
  var topSeciton: some View {
      HStack(spacing: 8) {
        Text(viewModel.name)
          .font(.largeTitle)
          .fontWeight(.semibold)
          .foregroundColor(.themeStyle.theme.primary)
          
          Spacer()
          
          Button(action: {
              isProfileViewPresented = true
          }) {
            Image(systemName: "person")
              .frame(width: 48, height: 48)
              .foregroundColor(.black)
              .background(Color.white)
              .cornerRadius(16)
          }
      }
      .padding(.vertical)
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
        Text("\(activitySessionManager.elapsedSeconds.formatTimeInterval)")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.themeStyle.theme.accent)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(Color.themeStyle.theme.black)
    .cornerRadius(16)
    .onTapGesture {
        viewModel.isRecordViewPresented.toggle()
    }
  }
  
  var weeklySummarySection: some View {
      VStack {
          MainViewSectionHeader(sectionTitle: "This week".capitalized)
          
          VStack {
              HStack(spacing: 8) {
                  totalElapsedTimeCard
                  totalDistanceCard
                  avgSpeedCard
              }
              .padding()
          }
          .background(Color.themeStyle.theme.secondaryBackground)
          .cornerRadius(16)
      }
  }
  
  var activitiesSeciton: some View {
    VStack(spacing: 8) {
        MainViewSectionHeader(sectionTitle: "Activites".capitalized)
      
        VStack(spacing: 16) {
            ForEach(viewModel.activities) { activity in
                Button {
                    viewModel.selectedActivity = activity
                    isActivityViewPresented.toggle()
                } label: {
                    MainViewActivityCard(activity: activity)
                }
            }
        }
        .sheet(isPresented: $isActivityViewPresented) {
//            if let selectedWorkout = viewModel.selectedActivity  {
//                let dependency = CyclingActivityViewModelDependencyImp(logger: viewModel.dependency.logger)
//                let viewModel = CyclingActivityViewModel(dependency: dependency,
//                                                         healthStoreManager: viewModel.healthStoreManager,
//                                                         activity: selectedWorkout)
//                CyclingActivityView(viewModel: viewModel).presentationDetents([.large])
//            }
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
              .font(.title3)
              .fontWeight(.bold)
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
    var totalDistanceCard: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("\(String(format: "%.1f", viewModel.weeklySummary.totalDistanceKilometers))")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeStyle.theme.accent)
                Text("km")
                  .foregroundColor(.themeStyle.theme.secondaryTextColor)
                  .font(.caption)
            }
            .frame(maxWidth: .infinity)
            
            Text("Distance")
              .foregroundColor(.themeStyle.theme.secondaryTextColor)
              .font(.caption2)
        }
    }
    
    var totalElapsedTimeCard: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(viewModel.weeklySummary.totalElapsedTime.shorterFormatInterval)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeStyle.theme.accent)
            }
            .frame(maxWidth: .infinity)
            
            Text("Elapsed Time")
              .foregroundColor(.themeStyle.theme.secondaryTextColor)
              .font(.caption2)
        }
    }
  
    var avgSpeedCard: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(viewModel.weeklySummary.averageSpeed.formatAvgSpeedTimeInterval)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.themeStyle.theme.accent)
                Text("/ km")
                  .foregroundColor(.themeStyle.theme.secondaryTextColor)
                  .font(.caption)
            }
            .frame(maxWidth: .infinity)
            
            Text("Speed")
              .foregroundColor(.themeStyle.theme.secondaryTextColor)
              .font(.caption2)
        }
    }
}

struct MainViewActivityCard: View {
    var activity: Activity
    var activityType: SportType
    var formmatedStartDate: String
    var totalEnergyBurned: Double
  
    init(activity: Activity) {
        self.activity = activity
        activityType = SportType(activityType: activity.workoutActivityType)
        
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
