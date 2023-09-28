//
//  RecordViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/28.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine

protocol RecordViewModelDependency {
    var logger: Logger { get }
    var locationManager: LocationManager { get }
}

class RecordViewModelDependencyImp: RecordViewModelDependency {
    var logger: Logger
    var locationManager: LocationManager
    
    init(logger: Logger, locationManager: LocationManager) {
        self.logger = logger
        self.locationManager = locationManager
    }
}

class RecordViewModel: ObservableObject {
    var dependency: RecordViewModelDependency
    @ObservedObject var locationManager: LocationManager
    @Published var location: CLLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)   // Default to San Francisco
    @Published var region: MKCoordinateRegion =  MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
        _locationManager = ObservedObject(wrappedValue: dependency.locationManager)

        locationManager.$location
            .assign(to: \.location, on: self)
            .store(in: &cancellables)
        
        locationManager.$region
            .assign(to: \.region, on: self)
            .store(in: &cancellables)
    }
}
