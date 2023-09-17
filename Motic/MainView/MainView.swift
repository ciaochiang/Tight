//
//  MainView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import HealthKit

struct MainView: View {
  @StateObject var viewModel: MainViewModel = MainViewModel()
  
  var body: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          topBar
          heartRateWidgetCard
          zoneWidgetCard
          MainViewSectionHeader(sectionTitle: "Activities")
          activitiesWidgetCard
          Spacer()
          bottomBar
        }
        .padding(30)
      }
    }
    .background(Color.gray.ignoresSafeArea())
    .onAppear {
      viewModel.healthStoreManager.retrieveOneMonthActivities()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

// MARK: COMPONENTS
extension MainView {
  var topBar: some View {
    HStack {
      Text("Ciao Chiang")
        .font(.headline)
      Spacer()
      Image(systemName: "person")
        .frame(width: 30, height: 30)
        .foregroundColor(.white)
        .background(Color.green)
        .cornerRadius(15)
    }
  }
  
  var bottomBar: some View {
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
  
  var heartRateWidgetCard: some View {
    VStack {
      HStack {
        Image(systemName: "heart.fill")
          .foregroundColor(viewModel.isHeartRateAuthoized == .sharingAuthorized ? .pink : .gray)
        Text("Heart Rate")
          .fontWeight(.medium)
          .foregroundColor(viewModel.isHeartRateAuthoized == .sharingAuthorized ? .black : .gray)
        
        Spacer()
        Text(viewModel.isHeartRateAuthoized == .sharingAuthorized ? "\(Int(viewModel.healthStoreManager.latestHeartRate.value)) BPM" : "")
          .font(.caption)
          .foregroundColor(Color.black)
      }
      .padding(16)
    }
    .frame(height: 60)
    .frame(maxWidth: .infinity)
    .background(Color.white)
    .cornerRadius(8)
    .shadow(radius: 12)
    .onAppear {
      viewModel.healthStoreManager.startObserveHeartRateSamples()
    }
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
    VStack {
      HStack {
        Image(systemName: "flame.fill")
          .foregroundColor(.pink)
        Text("Zone").fontWeight(.medium).foregroundColor(.black)
        Spacer()
        Text("\(viewModel.healthStoreManager.currentZone?.zoneName ?? "")")
          .font(.caption)
          .foregroundColor(.black)
      }
      .padding(16)
    }
    .frame(height: 60)
    .frame(maxWidth: .infinity)
    .background(Color.white)
    .cornerRadius(8)
    .shadow(radius: 12)
  }
  
  var activitiesWidgetCard: some View {
    VStack(spacing: 16) {
      ForEach(viewModel.healthStoreManager.activities, id: \.self) { activity in
        VStack {
          HStack {
            Image(systemName: "figure.indoor.cycle")
              .foregroundColor(.pink)
            Text("Indoor Cycling")
              .font(.caption)
              .foregroundColor(.black)
            Spacer()
          }
          .padding(16)
          .frame(height: 40)
          
          
          HStack {
            Text("Duration: xxxx s").font(.title2).foregroundColor(.black)
          }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 12)
      }
    }
  }
}

struct MainViewSectionHeader: View {
  let sectionTitle: String
  
  var body: some View {
    HStack {
      Text(sectionTitle)
        .font(.headline)
      Spacer()
    }
    .frame(height: 60)
    .frame(maxWidth: .infinity)
  }
}
