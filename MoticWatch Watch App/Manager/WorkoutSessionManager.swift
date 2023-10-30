//
//  WorkoutSessionManager.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/9/15.
//

import Foundation
import SwiftUI
import HealthKit

protocol WorkoutSessionManagerDelegate: AnyObject {
    func didReceived(heartRate: Double)
}

class WorkoutSessionManager: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    @State var healthStore = HKHealthStore()
    @Published var workoutSessionIsStarted: Bool = false
    @Published var heartRate: Double = 0.0
    var workoutSession: HKWorkoutSession?
    var heartRateObserverQuery: HKObserverQuery?
    weak var delegate: WorkoutSessionManagerDelegate?
  
    let infoToRead = Set([
        HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
        HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKSampleType.quantityType(forIdentifier: .heartRate)!,
        HKSampleType.workoutType()
    ])
                
    let infoToWrite = Set([
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.workoutType()
    ])
  
    func authorizeHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead) { (success, error) in
                if success {
                    // Do nothing
                } else {
                    // Handle authorization failure
                    print("HealthKit authorization denied.")
                }
            }
        } else {
            print("Health data is not supported.")
        }
    }
  
    func createWorkoutSession(activityType: HKWorkoutActivityType = .running) {
        // Create a workout configuration
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = activityType
          
        do {
            // Start a workout session
            workoutSession = try HKWorkoutSession(healthStore: healthStore,
                                                  configuration: workoutConfiguration)
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: nil)
        } catch {
          // Handle error
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
  
    func stopWorkoutSession() {
        workoutSession?.end()
    }
  
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        if toState == .running {
            // The workout session is running, and you can start receiving heart rate data
            print("worksession is running")
            toggle(isStarted: true)
        } else if toState == .ended {
            print("worksession is ended")
            toggle(isStarted: false)
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Handle session failure
        print(error)
    }
    
    func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { (success, error) in
            if success {
                let heartRateQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, error) in
                    self.fetchHeartRateData()
                }
                self.heartRateObserverQuery = heartRateQuery
                self.healthStore.execute(heartRateQuery)
            } else {
                // Handle authorization failure
            }
        }
    }
    
    func stopHeartRateMonitoring() {
        guard let heartRateQuery = heartRateObserverQuery else { return }
        healthStore.stop(heartRateQuery)
    }
    
    private func fetchHeartRateData() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    self.heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    self.delegate?.didReceived(heartRate: self.heartRate)
                }
            }
        }
        healthStore.execute(heartRateQuery)
    }
  
//  func sendHeartRate(heartRate: Double) {
//    if WCSession.default.isReachable {
//      print("session is reachable")
//      let message = ["heartRate": heartRate]
//      connectivityProvider.send(message: message)
//    }
//  }
  
//  func fetchHeartRateSamples(workoutSession: HKWorkoutSession) {
//
//    let dateFormmater = DateFormatter()
//    dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//    let targetTimezone = TimeZone(identifier: "UTC")!
//
//    dateFormmater.timeZone = targetTimezone
//    guard let startDate = workoutSession.startDate else { return }
//    let startDateStr = dateFormmater.string(from: startDate)
//    let targetStartDate = dateFormmater.date(from: startDateStr)
//    print("targetDateStr: \(startDateStr), target start date: \(targetStartDate)")
//
//    // Create a predicate to fetch heart rate samples
//    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//    let predicate = HKQuery.predicateForSamples(withStart: targetStartDate,
//                                                end: Date(),
//                                                options: .strictStartDate)
//
//
//
//    dateFormmater.timeZone = TimeZone.current
//
//    // Create a query to fetch heart rate samples
//    let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, results, error) in
//        if let results = results as? [HKQuantitySample] {
//          if let lastSample = results.last {
//            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
//            let heartRate = lastSample.quantity.doubleValue(for: heartRateUnit)
//            let sampleDate = dateFormmater.string(from: lastSample.startDate)
//            print("Heart Rate: \(heartRate) BPM , Date: \(lastSample.startDate)")
//            self.sendHeartRate(heartRate: heartRate)
//          }
//        } else if let error = error {
//            print("Error fetching heart rate samples: \(error.localizedDescription)")
//        }
//    }
//
//    // Execute the query
//    healthStore.execute(query)
//  }
}

extension WorkoutSessionManager {
    private func toggle(isStarted: Bool) {
        DispatchQueue.main.async {
            self.workoutSessionIsStarted = isStarted
        }
    }
}
