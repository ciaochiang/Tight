//
//  RecordView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/28.
//

import SwiftUI
import MapKit

// MapView
// - show map center in current location (V)
// - start / end point
// - route
// Close Button
// Time Counter
// Distance
// Avg. Speed
// Heart Rate (if applicable)
// Elvation
// Weather (optional, https://developer.apple.com/weatherkit/ would requird fees)
// Pause/Resume Button
// End Avtivity

/**
 
 - 1. Check location permission when view is appeared
 */

struct RecordView: View {
    @StateObject private var viewModel: RecordViewModel
    @StateObject private var activitySessionManager: ActivitySessionManager
    @StateObject private var wearableDeviceManager: WearableDeviceManager
    @Binding private var isPresented: Bool
    
    init(viewModel: RecordViewModel, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _activitySessionManager = StateObject(wrappedValue: viewModel.dependency.activitySessionManager)
        _wearableDeviceManager = StateObject(wrappedValue: viewModel.dependency.wearableDeviceManager)
        _isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            NavigationView {
                ZStack(alignment: .bottom) {
                    MapView(region: $activitySessionManager.region).ignoresSafeArea(edges: .bottom)
                    RecordPanelView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .navigationTitle("Record")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: activitySessionManager.isRecording
                                  ? "chevron.down"
                                  : "xmark")
                                .foregroundColor(.themeStyle.theme.primary)
                        }
                    }
                }
            }
            .environmentObject(viewModel)
            .environmentObject(activitySessionManager)
            .environmentObject(wearableDeviceManager)
            .sheet(isPresented: $viewModel.isLocationBottomSheetPresented) {
                LocationPermissionDialogView {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    
                    DispatchQueue.main.async {
                        self.viewModel.isLocationBottomSheetPresented.toggle()
                    }
                }
            }
            .sheet(isPresented: $viewModel.isSportSelectorPresented) {
                let depdendency = SportSelectorViewModelDependencyImp(logger: viewModel.dependency.logger)
                let sportSelectorViewModel = SportSelectorViewModel(dependency: depdendency)
                SportSelectorView(viewModel: sportSelectorViewModel,
                                  isPresented: $viewModel.isSportSelectorPresented) { sport in
                    viewModel.selectedSport = sport
                }
            }
            .sheet(isPresented: $viewModel.isWearableDeviceSelectorPresented) {
                let dependency = WearableDeviceMainViewModelDependencyImp(
                    logger: viewModel.dependency.logger,
                    wearableDeviceManager: wearableDeviceManager)
                let viewModel = WearableDeviceMainViewModel(dependency: dependency)
                WearableDeviceMainView(viewModel: viewModel, isPresented: $viewModel.isWearableDeviceSelectorPresented)
            }
        }
        .onAppear {
            viewModel.validateLocationAuthorization()
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        let wdManagerDependency = WearableDeviceManagerDependencyImp(logger: Mocks.logger)
        let wdManager = WearableDeviceManager(dependency: wdManagerDependency)
        
        let dependency = RecordViewModelDependencyImp(logger: Mocks.logger,
                                                      activitySessionManager: ActivitySessionManager.shared, wearableDeviceManager: wdManager)
        let viewModel = RecordViewModel(dependency: dependency)
        
        Group {
            RecordView(viewModel: viewModel, isPresented: .constant(true))
        }
    }
}

struct MapView: View {
    @Binding private var region: MKCoordinateRegion
    @EnvironmentObject var activitySessionManager: ActivitySessionManager
    
    init(region: Binding<MKCoordinateRegion>) {
        _region = region
    }
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear {
                activitySessionManager.startUpdatingLocation()
            }
    }
}

struct RecordPanelView: View {
    @EnvironmentObject var viewModel: RecordViewModel
    @EnvironmentObject var activitySessionManager: ActivitySessionManager
    @EnvironmentObject var wearableDeviceManager: WearableDeviceManager
    
    var body: some View {
        VStack {
            HStack(spacing: 32) {
                sportSelection
                wearableDeviceSelection
            }
            activeTimeCounter.padding()
            metricSection
            startButton
        }
        .background(Color.themeStyle.theme.secondaryBackground.opacity(0.9))
        .cornerRadius(16)
    }
    
    var sportSelection: some View {
        VStack {
            Image(systemName: viewModel.selectedSport.systemIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .onTapGesture {
                    viewModel.isSportSelectorPresented.toggle()
                }

        }
        .padding(.top)
    }
    
    var wearableDeviceSelection: some View {
        VStack {
            Image(systemName: "applewatch")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundColor(wearableDeviceManager.isDeviceConnected ? .orange : .black)
                .onTapGesture {
                    viewModel.isWearableDeviceSelectorPresented.toggle()
                }

        }
        .padding(.top)
    }
    
    var activeTimeCounter: some View {
        VStack {
            Text(activitySessionManager.recordingState == .paused
                 ? "\(activitySessionManager.restElapsedSeconds.formatTimeInterval)"
                 : "\(activitySessionManager.acitveElapsedSeconds.formatTimeInterval)")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.themeStyle.theme.primary)
        }
        .onReceive(activitySessionManager.timer) { _ in
            activitySessionManager.handleTimerAction()
        }
    }
    
    var metricSection: some View {
        HStack {
            VStack {
                Text(String(format: "%.1f", activitySessionManager.totalDistance))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeStyle.theme.green)
                Text("Distance")
                    .font(.caption)
                    .foregroundColor(.themeStyle.theme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("152")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeStyle.theme.green)
                Text("Heart Rate")
                    .font(.caption)
                    .foregroundColor(.themeStyle.theme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text(String(format: "%1.f", activitySessionManager.currentSpeed))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.themeStyle.theme.green)
                Text("Speed")
                    .font(.caption)
                    .foregroundColor(.themeStyle.theme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    var startButton: some View {
        HStack(spacing: 8) {
            if viewModel.dependency.activitySessionManager.recordingState == .notStarted {
                Button {
                    activitySessionManager.isRecording
                    ? viewModel.stopSession()
                    : viewModel.startSession()
                } label: {
                    Text(activitySessionManager.isRecording  ? "PASUE" : "START")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
                .background(activitySessionManager.isRecording
                            ? Color.themeStyle.theme.red
                            : Color.themeStyle.theme.green)
                .foregroundColor(.themeStyle.theme.black)
                .cornerRadius(8)
                .padding()
            } else {
                Button {
                    // Pause
                    activitySessionManager.recordingState == .recording
                    ? viewModel.pauseSession()
                    : viewModel.resumeSession()
                } label: {
                    Text(activitySessionManager.recordingState == .recording  ? "PAUSE" : "RESUME")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
                .background(Color.themeStyle.theme.green)
                .foregroundColor(.themeStyle.theme.black)
                .cornerRadius(8)
                .padding(.vertical)
                .padding(.leading)
                
                Button {
                    // Stop
                    viewModel.stopSession()
                } label: {
                    Text("END")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
                .background(Color.themeStyle.theme.green)
                .foregroundColor(.themeStyle.theme.black)
                .cornerRadius(8)
                .padding(.vertical)
                .padding(.trailing)
            }
        }
       
    }
}


struct LocationPermissionDialogView: View {
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Image
            
            // Headline
            Text("Require your location")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
            Text("Location authorization is required for updating your location on the map.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .foregroundColor(.themeStyle.theme.secondaryTextColor)
            
            Spacer()
            
            Button {
                // Go to setting
                action()
            } label: {
                Text("Turn on location".uppercased())
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.themeStyle.theme.black)
            .foregroundColor(.themeStyle.theme.white)
            .cornerRadius(16)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themeStyle.theme.background)
        .presentationDetents([.medium])
    }
}
