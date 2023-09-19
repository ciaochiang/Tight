//
//  LocationManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
  private var locationManager = CLLocationManager()
  @Published var status: CLAuthorizationStatus = .notDetermined
  
  override init() {
    super.init()
    locationManager.delegate = self
  }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
  func requestLocationPermission() {
    locationManager.requestAlwaysAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // Handle the authorization status change here
    self.status = status
  }
}
