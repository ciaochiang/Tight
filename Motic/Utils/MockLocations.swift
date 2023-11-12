//
//  MockLocations.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/12.
//

import MapKit

extension MKCoordinateRegion {
    static let sanfrancisco = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )
    
    static let home = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.9766591, longitude: 121.5435001), // Home
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )
    
    static let test = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7802, longitude: -122.4848),
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
}

extension CLLocationCoordinate2D {
    static let sanfrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
}

