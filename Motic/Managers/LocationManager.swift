//
//  LocationManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)   // Default to San Francisco
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
}

// MARK: Functions
extension LocationManager {
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func accumulateDistance(lastRecordedLocation: CLLocation?,
                            newLocation: CLLocation) -> Double {
        guard let recordedLocation = lastRecordedLocation else { return 0 }
        
        let distance = newLocation.distance(from: recordedLocation)
        return distance
    }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle the authorization status change here
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.currentLocation = lastLocation
        }
    }
}


struct Location {
    let longitude: Double
    let latitude: Double
    let altitude: Double
    let ellipsoidalAltitude: Double
    let speed: Double
    let course: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let courseAccuracy: Double
    let speedAccuracy: Double
    let timestamp: Date
    let isSimulatedBySoftware: Bool?
    let isProducedByAccessory: Bool?
    
    init(location: CLLocation) {
        self.longitude = location.coordinate.longitude
        self.latitude = location.coordinate.latitude
        self.altitude = location.altitude
        self.ellipsoidalAltitude = location.ellipsoidalAltitude
        self.speed = location.speed
        self.course = location.course
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.speedAccuracy = location.speedAccuracy
        self.courseAccuracy = location.courseAccuracy
        self.timestamp = location.timestamp
        self.isSimulatedBySoftware = location.sourceInformation?.isSimulatedBySoftware
        self.isProducedByAccessory = location.sourceInformation?.isProducedByAccessory
    }
    
    func toCLLocation() -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                          altitude: altitude,
                          horizontalAccuracy: horizontalAccuracy,
                          verticalAccuracy: verticalAccuracy,
                          course: course,
                          courseAccuracy: courseAccuracy,
                          speed: speed,
                          speedAccuracy: speedAccuracy,
                          timestamp: timestamp,
                          sourceInfo: CLLocationSourceInformation(softwareSimulationState: isSimulatedBySoftware ?? false, andExternalAccessoryState: isProducedByAccessory ?? false))
    }
}
