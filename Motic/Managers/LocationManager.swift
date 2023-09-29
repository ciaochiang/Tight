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
    @Published var location: CLLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)   // Default to San Francisco
    @Published var region: MKCoordinateRegion =  MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
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
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      // Handle the authorization status change here
      self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            DispatchQueue.main.async {
                self.location = lastLocation
                self.region.center = lastLocation.coordinate
            }
        }
    }
}
