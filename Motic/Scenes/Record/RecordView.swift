//
//  RecordView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/28.
//

import SwiftUI
import MapKit

// MapView
// - start / end point
// - route
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
    
    init(viewModel: RecordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack(alignment: .bottom) {
                    MapView(region: $viewModel.region).ignoresSafeArea(edges: .bottom)
                        .navigationTitle("Record")
                        .navigationBarTitleDisplayMode(.inline)
                    RecordPanelView()
                        .frame(maxHeight: 240)
                        .frame(maxWidth: .infinity)
                        .padding()
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
        let dependency = RecordViewModelDependencyImp(logger: Mocks.logger, locationManager: locationManager)
        let viewModel = RecordViewModel(dependency: dependency)
        RecordView(viewModel: viewModel)
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
            Spacer()
            VStack {
                VStack {
                    VStack {
                        Text("3:56:11")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.themeStyle.theme.primary)
                    }
                    .padding()
                    
                    HStack {
                        VStack {
                            Text("3:56:11")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.themeStyle.theme.red)
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            Text("152")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.themeStyle.theme.red)
                            Text("Heart Rate")
                                .font(.caption)
                                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            Text("3'11\"")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.themeStyle.theme.red)
                            Text("Speed")
                                .font(.caption)
                                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)

                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
                Button {
                    
                } label: {
                    Text("START")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
                .background(Color.themeStyle.theme.blue)
                .foregroundColor(.themeStyle.theme.white)
                .cornerRadius(8)
                .padding()
            }
        }
        .background(Color.themeStyle.theme.secondaryBackground.opacity(0.9))
        .cornerRadius(16)
    }
}
