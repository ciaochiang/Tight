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

struct RecordView: View {
    @StateObject private var viewModel: RecordViewModel
    @Binding private var isPresented: Bool
    
    init(viewModel: RecordViewModel, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            NavigationView {
                ZStack(alignment: .bottom) {
                    MapView(region: $viewModel.region).ignoresSafeArea(edges: .bottom)
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
                            Image(systemName: "xmark")
                                .foregroundColor(.themeStyle.theme.primary)
                        }

                    }
                }
            }
        }
        .onAppear {
            viewModel.locationManager.startUpdatingLocation()
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        let locationManager = LocationManager()
        let dependency = RecordViewModelDependencyImp(logger: Mocks.logger,
                                                      locationManager: locationManager)
        let viewModel = RecordViewModel(dependency: dependency)
        RecordView(viewModel: viewModel, isPresented: .constant(true))
    }
}

struct MapView: View {
    @Binding private var region: MKCoordinateRegion
    
    init(region: Binding<MKCoordinateRegion>) {
        _region = region
    }
    
    var body: some View {
        Map(coordinateRegion: $region)
    }
}

struct RecordPanelView: View {
    var body: some View {
        VStack {
            timeCounter.padding()
            metricSection
            startButton
        }
        .background(Color.themeStyle.theme.secondaryBackground.opacity(0.9))
        .cornerRadius(16)
    }
    
    var timeCounter: some View {
        VStack {
            Text("3:56:11")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.themeStyle.theme.primary)
        }
    }
    
    var metricSection: some View {
        HStack {
            VStack {
                Text("3:56:11")
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
                Text("3'11\"")
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
        Button {
            
        } label: {
            Text("START")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 60)
        .background(Color.themeStyle.theme.green)
        .foregroundColor(.themeStyle.theme.black)
        .cornerRadius(8)
        .padding()
    }
}
