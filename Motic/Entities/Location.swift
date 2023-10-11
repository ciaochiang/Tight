//
//  Location.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/11.
//

import CoreLocation

struct Location {
    let id: String = UUID().uuidString
    let activityId: String
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
    
    init(activityId: String, location: CLLocation) {
        self.activityId = activityId
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
