//
//  ActivitySessionManager .swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/2.
//

import CoreLocation
import SwiftUI
import MapKit
import Combine

class ActivitySessionManager: NSObject, ObservableObject {
    /*
     Singleton instance for recording metadata across app.
     */
    static let shared = ActivitySessionManager()
    
    var locationManager = CLLocationManager()
    private var logger: Logger
    private var storeManager: CoreDataManager
    
    @Published var recordingState: RecordingState = .notStarted
    @Published var isRecording: Bool = false
    @Published var workoutType: SportType = .others
    @Published var session: ActivitySession?
    @Published var acitveElapsedSeconds: TimeInterval = 0.0
    @Published var restElapsedSeconds: TimeInterval = 0.0
    @Published var coolElapsedSeconds: TimeInterval = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var cachedLocations: [Location] = []
    @Published var totalDistance: Double = 0.0
    @Published var distances: [Distance] = []
    @Published var heartRates: [HeartRate] = []
    @Published var lastPausedTimestamp: Date?
    var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    
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
    
    /**
     Invoke this function when user clicked "start" button on record view
     */
    func startSession(with workoutType: SportType = .cycling) {
        guard recordingState == .notStarted else { return }
                
        // Init timer
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        self.workoutType = workoutType
        createSessionIfNeeded(workoutType: workoutType)
        
        // Enable location background mode
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        isRecording = true
        recordingState = .recording
        
        // Add active timestamp to timeline
        session?.addElapasedTime(status: .active, timestamp: session?.startTime ?? Date())
        
        logger.log("Session is started", level: .info)
    }
    
    /**
     Invoke this function to resume recording
     */
    func resumeSession() {
        guard recordingState == .paused else { return }
        
        isRecording = true
        recordingState = .recording
        
        // Add active timestamp to timeline
        session?.addElapasedTime(status: .active, timestamp: Date())
    }
    
    /**
     Invoke this function to pause recording
     */
    func pauseSession() {
        guard recordingState == .recording, session != nil else { return }
        
        lastPausedTimestamp = Date()
        
        isRecording = false
        recordingState = .paused
        
        // Add rest timestamp to timeline
        session?.addElapasedTime(status: .rest, timestamp: Date())
    }
    
    /**
     Invoke this function when user clicked "stop" button on record view
     */
    func stopSession() {
        logger.log("Session is ended", level: .info)

        guard recordingState == .recording || recordingState == .paused else { return }
        
        timer.upstream.connect().cancel()
        
        /**
         Update states
         */
        isRecording = false
        recordingState = .notStarted
        session?.endTime = Date()
        
        /**
         Save to core data
         */
        if let session = session {
            // Save activity
            storeManager.saveActivity(with: session)
            
            // Save locations
            storeManager.saveLocations(with: cachedLocations, session: session)
            
            logger.log("Data is saved", level: .info)
        }
        
        /**
        Clean up
         */
        session = nil
        currentLocation = nil
        acitveElapsedSeconds = 0.0
        currentSpeed = 0.0
        totalDistance = 0.0
        cachedLocations = []
        distances = []
        heartRates = []
        
        // Disable location background mode
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        
        logger.log("\(session?.timeline ?? [])", level: .info)
    }
}

// MARK: Public functions
extension ActivitySessionManager {
    func handleTimerAction() {
        if recordingState == .recording {
            acitveElapsedSeconds += 1
            session?.activeElapsedSeconds = acitveElapsedSeconds
        }
        else if recordingState == .paused {
            restElapsedSeconds += 1
            session?.restElapsedSeconds = restElapsedSeconds
        }
    }
}

// MARK: Private fucntions
extension ActivitySessionManager {
    @discardableResult private func createSessionIfNeeded(workoutType: SportType) -> ActivitySession? {
        if session == nil {
            session = ActivitySession(workoutType: workoutType, startTime: Date())
        }
        
        return session
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
    var activeElapsedSeconds: Double = 0
    var restElapsedSeconds: Double = 0
    var timeline: [ElapsedTime] = []
    var startTime: Date
    var endTime: Date?
    
    mutating func addElapasedTime(status: ElapsedTimeStatus, timestamp: Date) {
        let elapsedTime = ElapsedTime(activityId: id, status: status, timestamp: timestamp)
        timeline.append(elapsedTime)
    }
}

enum ElapsedTimeStatus: Int {
    case active
    case rest
}

struct ElapsedTime: Identifiable {
    let id: String = UUID().uuidString
    var activityId: String
    var status: ElapsedTimeStatus
    var timestamp: Date
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

enum RecordingState {
    case notStarted
    case recording
    case paused
}

