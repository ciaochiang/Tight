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
      Color(UIColor.secondarySystemBackground).ignoresSafeArea()
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
          .foregroundColor(.primary)
        Text("Ciao Chiang")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
      }

      Spacer()
      Image(systemName: "person")
        .frame(width: 60, height: 60)
        .foregroundColor(.black)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color(UIColor(white: 1, alpha: 0.7)), radius: 4)
    }
  }
  
  var currentActivitySection: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Working Out...")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.white)
        Text("Indoor Cycling")
          .font(.subheadline)
          .fontWeight(.regular)
          .foregroundColor(.accentColor)
      }
      Spacer()
      VStack(alignment: .center) {
        Text("1:30:20")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.white)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(Color.black)
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
        ForEach(0..<4) { _ in
          MainViewActivityCard()
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
      .foregroundColor(.white)
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
        .foregroundColor(Color.primary)
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
          .foregroundColor(viewModel.isHeartRateAuthoized == .sharingAuthorized ? .pink : .gray)
          .frame(width: 12, height: 12)
          .scaledToFit()
        Text("Heart Rate")
          .foregroundColor(viewModel.isHeartRateAuthoized == .sharingAuthorized ? .primary : .gray)
          .font(.caption)
          .fontWeight(.semibold)
      }
      .padding(16)
      HStack(spacing: 8) {
        Text(viewModel.isHeartRateAuthoized == .sharingAuthorized ? "\(Int(viewModel.healthStoreManager.latestHeartRate.value))" : "0")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(viewModel.isHeartRateAuthoized == .sharingAuthorized ? .pink : .gray)
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
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .onTapGesture {
      if viewModel.isHeartRateAuthoized != .sharingAuthorized {
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
          .foregroundColor(.pink)
          .frame(width: 12, height: 12)
          .scaledToFit()
        Text("Zone")
          .foregroundColor(.primary)
          .font(.caption)
          .fontWeight(.semibold)
      }
      .padding(16)
      HStack(spacing: 8) {
        Text("\(viewModel.healthStoreManager.currentZone?.zoneName ?? "Zone 1")")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(Color.pink)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity)
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
  }
}

struct MainViewActivityCard: View {
//  @State var activtiy: HKWorkout
//
//  init(activity: HKWorkout) {
//    self.activtiy = activity
//  }
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: "figure.indoor.cycle")
        .resizable()
        .scaledToFit()
        .foregroundColor(Color(UIColor.systemPink))
        .frame(maxWidth: 16)
      VStack(alignment: .leading, spacing: 4) {
        Text("Indoor Cycling")
          .font(.caption)
          .foregroundColor(.secondary)
        Text("360.18 Kcal")
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        Text("30 mins")
          .fontWeight(.semibold)
          .foregroundColor(.primary)
      }
      
      Spacer()

    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
  }
}
