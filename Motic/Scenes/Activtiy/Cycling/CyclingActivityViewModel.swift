//
//  CyclingActivityViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/20.
//

import SwiftUI
import HealthKit

// Temp struct
struct ChartData<T>: Identifiable {
  let id = UUID()
  var date: Date
  var value: T

  init(date: Date, value: T) {
    self.date = date
    self.value = value
  }
}

protocol CyclingActivityViewModelDependency {
  var logger: Logger { get }
}

class CyclingActivityViewModelDependencyImp: CyclingActivityViewModelDependency {
  var logger: Logger
  
  init(logger: Logger) {
    self.logger = logger
  }
}

class CyclingActivityViewModel: ObservableObject {
  var dependency: CyclingActivityViewModelDependency
  var workout: HKWorkout
  @Published var healthStoreManager: HealthStoreManager
  
  // MARK: Basic
  @Published var workoutType: WorkoutActivityType
  @Published var duraiton: TimeInterval
  @Published var timezone: TimeZone?
  
  // MARK: Heart Rate
  @Published var avgHeartRate: Double = 0
  @Published var heartRateSamples: [ChartData<Double>] = []
  @Published var heartRateZones: HeartRateZones
  @Published var zones: [Zone]?
    
  // MARK: Distance
  @Published var totalDistanceMeters: Double
  @Published var distanceSamples: [ChartData<Double>]?
  @Published var elevationAscendedMeters: Double?
  
  // MARK: Speed
  @Published var avgSpeedPerHour: Double = 0
  
  // MARK: Energy
  @Published var basalEnergyBurned: Double?
  @Published var basalEnergyBurnedSamples: [ChartData<Double>]?
  @Published var activeEnergyBurned: Double?
  @Published var activeEnergyBurnedSamples: [ChartData<Double>]?
  @Published var avgMETs: Double?
  
  // MARK: Weather
  @Published var weatherTemperatureCelsius: Double?
  @Published var weatherHumidity: Double?
  
  
  init(dependency: CyclingActivityViewModelDependency,
       healthStoreManager: HealthStoreManager,
       workout: HKWorkout) {
    self.dependency = dependency
    _healthStoreManager = Published(wrappedValue: healthStoreManager)
    self.workout = workout
    self.duraiton = workout.duration
    self.avgMETs = healthStoreManager.getAvgMETs(from: workout)
    self.weatherTemperatureCelsius = healthStoreManager.getWeatherTemperatureCelsius(from: workout)
    self.weatherHumidity = healthStoreManager.getWeatherHumidity(from: workout)
    self.elevationAscendedMeters = healthStoreManager.getElavationAscendedMeters(from: workout)
    self.timezone = healthStoreManager.getTimezone(from: workout)
    self.heartRateZones = HeartRateZones(maxHeartRate: 194)
    self.totalDistanceMeters = healthStoreManager.getTotalDistanceMeters(workout: workout)
    self.workoutType = WorkoutActivityType(activityType: workout.workoutActivityType)

    // After initialization
    self.avgSpeedPerHour = healthStoreManager.getAvgSpeedPerHour(duration: self.duraiton,
                                                                 totalDistanceMeters: self.totalDistanceMeters)
    
    if let metadata = workout.metadata {
      dependency.logger.log("Metadata: \(metadata)", level: .info)
      dependency.logger.log("All Statistics: \(workout.allStatistics)", level: .info)
    }
    
    
      // Get all heart rate metadata
      Task {
          do {
              let heartRates = try await healthStoreManager.getHearRateSamples(from: workout)
              let avgHeartRate = healthStoreManager.getAverage(by: heartRates)
              let zones = healthStoreManager.getHeartRateZoneDurations(from: heartRates, zones: heartRateZones.zones)

              await MainActor.run {
                  self.heartRateSamples = heartRates
                  self.avgHeartRate = avgHeartRate
                  self.zones = zones
              }
          }
          catch let error {
              dependency.logger.log(error.localizedDescription, level: .error)
          }
      }
      
    // Get all distance samples
    healthStoreManager.getAllDistanceSamples(workout: workout, identifier: .distanceWalkingRunning) { [weak self] data, _ in
      DispatchQueue.main.async {
        self?.distanceSamples = data
      }
    }
    
    // Get all energy burned samples
    healthStoreManager.getBasalEnergyBurnedSamples(from: workout) { [weak self] data, _ in
      // Calculate avg value
      let avgValue = healthStoreManager.getAvgValue(from: data)
      
      DispatchQueue.main.async {
        self?.basalEnergyBurned = avgValue
        self?.basalEnergyBurnedSamples = data
      }
    }
    
    healthStoreManager.getActiveEnergyBurnedSamples(from: workout) { [weak self] data, _ in
      // Calculate avg value
      let avgValue = healthStoreManager.getAvgValue(from: data)
      
      DispatchQueue.main.async {
        self?.activeEnergyBurned = avgValue
        self?.activeEnergyBurnedSamples = data
      }
    }
  }
  
  func getFormattedDuration(duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    
    if let formattedString = formatter.string(from: duration) {
        return formattedString
    } else {
        return "0s" // Default value or an error message
    }
  }
}
