//
//  ActivitySessionManager .swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/2.
//

import CoreLocation
import SwiftUI
import MapKit

class ActivitySessionManager: NSObject, ObservableObject {
    /*
     Singleton instance for recording metadata across app.
     */
    static let shared = ActivitySessionManager()
    
    var locationManager = CLLocationManager()
    private var logger: Logger
    private var storeManager: CoreDataManager
    
    @Published var isRecording: Bool = false
    @Published var workoutType: SportType = .others
    @Published var session: ActivitySession?
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var currentSpeed: Double = 0.0
    @Published var cachedLocations: [Location] = []
    @Published var totalDistance: Double = 0.0
    @Published var distances: [Distance] = []
    @Published var heartRates: [HeartRate] = []
    
    // Location
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var region: MKCoordinateRegion =  MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )
    
    override init() {
        logger = Logger(configuration: AppConfiguration.loggerConfig)
        
        let dependency = CoreDataManagerDependencyImp(logger: logger)
        storeManager = CoreDataManager(dependency: dependency)
        super.init()
        
        self.locationManager.delegate = self
        logger.log("ActivitySessionManager is inititated", level: .info)
    }
    
    /**
     Invoke this function then record view is appeared
     
     Enable `allowsBackgroundLocationUpdates`
     Disable `pausesLocationUpdatesAutomatically`

     */
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        logger.log("Location manager is updating locations", level: .info)
    }
    
    /**
     Invoke this function when record view is dismissed
    
     Disable `allowsBackgroundLocationUpdates`
     Enable `pausesLocationUpdatesAutomatically`
     
     */
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        logger.log("Location manager stopped to update locations", level: .info)
    }
    
    /*
     Invoke this function when user clicked "start" button on record view
     */
    func startSession(with workoutType: SportType = .cycling) {
        self.workoutType = workoutType
        createSessionIfNeeded(workoutType: workoutType)
        
        // Enable location background mode
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        isRecording.toggle()
        
        logger.log("Session is started", level: .info)
    }
    
    /*
     Invoke this function when user clicked "stop" button on record view
     */
    func stopSession() {
        isRecording.toggle()
        session?.endTime = Date()
        logger.log("Session is ended", level: .info)
        
        if let session = session {
            // Save activity
            storeManager.saveActivity(with: session)
            
            // Save locations
            storeManager.saveLocations(with: cachedLocations, session: session)
            
            logger.log("Data is saved", level: .info)
        }
        
        session = nil
        currentLocation = nil
        elapsedSeconds = 0.0
        currentSpeed = 0.0
        totalDistance = 0.0
        cachedLocations = []
        distances = []
        heartRates = []
        
        // Disable location background mode
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
    }
}

// MARK: Public functions
extension ActivitySessionManager {
    func handleTimerAction() {
        guard let session = session else { return }
        elapsedSeconds = -session.startTime.timeIntervalSinceNow
    }
}

// MARK: Private fucntions
extension ActivitySessionManager {
    private func createSessionIfNeeded(workoutType: SportType) {
        if session == nil {
            session = ActivitySession(workoutType: workoutType, startTime: Date())
        }
    }
    
    private func handleLocations(session: ActivitySession?, locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        // Update latest location
        Task {
            await MainActor.run(body: {
                self.currentLocation = lastLocation
                self.region.center = lastLocation.coordinate
            })
        }

        /*
         Below required 'isRecording' is true
         */
        // Calculate distance and append distance struct to list
        guard isRecording == true, let session = session else { return }
        
        // Calculate and store distance
        if let lastCachedLocation = cachedLocations.last,
            lastLocation.horizontalAccuracy > 0,
            lastLocation.verticalAccuracy > 0,
            lastLocation.speed >= 0 {
            let distance = calcualteDistance(from: lastCachedLocation, to: lastLocation)
            distances.append(Distance(distanceInMeter: distance, timestamp: lastLocation.timestamp))
            totalDistance += distance
        }
        
        // Update speed
        currentSpeed = lastLocation.speed

        // Append lcation to cachedLocations only if session is valid
        let location = Location(activityId: session.id, location: lastLocation)
        cachedLocations.append(location)
    }
    
    private func calcualteDistance(from lastLocation: Location?, to newLocation: CLLocation) -> Double {
        guard let lastLocation = lastLocation else { return 0 }
        
        let distance = newLocation.distance(from: lastLocation.toCLLocation())
        return distance
    }
}

// MARK: CLLocationManagerDelegate
extension ActivitySessionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle the authorization status change here
        locationAuthorizationStatus = status
    }
    
    // TODO: Enhance gps location accuracy like user is indoor or outdoor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        handleLocations(session: session, locations: locations)
        
        if let latestLocation = locations.last {
            if latestLocation.horizontalAccuracy < 0 {
                print("Failed to get a valid location.")
            } else if latestLocation.horizontalAccuracy > 100 { // Example: Accuracy more than 100 meters
                print("Low accuracy location.")
            } else {
                print("Received location with good accuracy: \(latestLocation)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else { return }
        
        switch clError.code {
        case .locationUnknown: // Location manager is currently unable to receive location data
            logger.log("No GPS signal or another issue", level: .error)
        case .denied: // User denied location use for the app
            logger.log("Location services denied by user.", level: .error)
        case .network: // Network-related error
            logger.log("Network issue.", level: .error)
        default:
            logger.log("Another location error occurred: \(error.localizedDescription)", level: .error)
        }
    }
}

// MARK: Structs
struct ActivitySession: Identifiable {
    let id: String = UUID().uuidString
    var workoutType: SportType
    var startTime: Date
    var endTime: Date?
}

struct HeartRate: Identifiable {
    let id: String = UUID().uuidString
    let heartRate: Double
    let timestamp: Date
}

struct Distance: Identifiable {
    let id: String = UUID().uuidString
    let distanceInMeter: Double
    let timestamp: Date
}


