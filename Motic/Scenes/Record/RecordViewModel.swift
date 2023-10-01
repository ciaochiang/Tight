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
    @Published var isRecording: Bool = false
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var totalDistance: Double = 0.0
    @Published var speed: Double = 0.0
    @Published var recordedLocations: [CLLocation] = []
    @Published var location: CLLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)   // Default to San Francisco
    @Published var region: MKCoordinateRegion =  MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )
    
    var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(dependency: RecordViewModelDependency) {
        self.dependency = dependency
        _locationManager = ObservedObject(wrappedValue: dependency.locationManager)
        
        locationManager.$currentLocation
            .assign(to: \.location, on: self)
            .store(in: &cancellables)
    }
}

extension RecordViewModel {
    func handleNewLocation(location: CLLocation) {
        // Update region center for map
        Task {
            await MainActor.run(body: {
                self.region.center = location.coordinate
                self.speed = location.speed
            })
        }
        
        if isRecording {
            totalDistance += locationManager.accumulateDistance(lastRecordedLocation: recordedLocations.last, newLocation: location)
            recordedLocations.append(location)
        }
    }
    
    
    func startRecording() {
        isRecording.toggle()
        startTime = Date()
    }
    
    func stopRecording() {
        isRecording.toggle()
        startTime = nil
        
        
        // Print
        dependency.logger.log("Recorded locations: \(recordedLocations)", level: .info)
    }
}

