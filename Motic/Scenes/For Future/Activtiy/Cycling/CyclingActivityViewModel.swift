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
  var logger: CustomLogger { get }
}

class CyclingActivityViewModelDependencyImp: CyclingActivityViewModelDependency {
  var logger: CustomLogger
  
  init(logger: CustomLogger) {
    self.logger = logger
  }
}

class CyclingActivityViewModel: ObservableObject {
    var dependency: CyclingActivityViewModelDependency
    var activity: Activity
    @Published var healthStoreManager: HealthStoreManager
  
    // MARK: Basic
    @Published var workoutType: SportType
    @Published var duraiton: TimeInterval
    @Published var timezone: TimeZone?
    
    // MARK: Heart Rate
    @Published var avgHeartRate: Double = 0
    @Published var heartRateSamples: [ChartData<Double>] = []
    @Published var heartRateZones: HeartRateZones
    @Published var zones: [Zone]?
    
    // MARK: Distance
    @Published var totalDistanceMeters: Double = 0.0
    @Published var distanceSamples: [ChartData<Double>]?
    @Published var elevationAscendedMeters: Double?
  
    // MARK: Speed
    @Published var avgSpeedPerHour: Double = 0
    
    // MARK: Energy
    @Published var basalEnergyBurned: Double?
    @Published var basalEnergyBurnedSamples: [ChartData<Double>]?
    @Published var activeEnergyBurned: Double?
    @Published var activeEnergyBurnedSamples: [ChartData<Double>]?
    @Published var avgMETs: Double? = nil
    
    // MARK: Weather
    @Published var weatherTemperatureCelsius: Double?
    @Published var weatherHumidity: Double?
  
  
  init(dependency: CyclingActivityViewModelDependency,
       healthStoreManager: HealthStoreManager,
       activity: Activity) {
      _healthStoreManager = Published(wrappedValue: healthStoreManager)
      
      self.dependency = dependency
      self.activity = activity
      self.duraiton = activity.workout.duration
      
      self.avgMETs = healthStoreManager.getAvgMETs(from: activity.workout)
      self.weatherTemperatureCelsius = healthStoreManager.getWeatherTemperatureCelsius(from: activity.workout)
      self.weatherHumidity = healthStoreManager.getWeatherHumidity(from: activity.workout)
      self.elevationAscendedMeters = healthStoreManager.getElavationAscendedMeters(from: activity.workout)
      self.timezone = healthStoreManager.getTimezone(from: activity.workout)
      self.heartRateZones = HeartRateZones(maxHeartRate: 194)
      self.totalDistanceMeters = healthStoreManager.getTotalDistanceMeters(workout: activity.workout)
      self.workoutType = SportType(activityType: activity.workoutActivityType)

      // After initialization
      self.avgSpeedPerHour = healthStoreManager.getAvgSpeedPerHour(duration: self.duraiton,
                                                                 totalDistanceMeters: self.totalDistanceMeters)
    
      if let metadata = activity.workout.metadata {
          dependency.logger.log("Metadata: \(metadata)", level: .info)
          dependency.logger.log("All Statistics: \(activity.workout.allStatistics)", level: .info)
      }
    
      // Get all heart rate metadata
      Task {
          do {
              let heartRates = try await healthStoreManager.getHearRateSamples(from: activity.workout)
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
      
      // Get all distance metadata
      Task {
          do {
              let distances = try await healthStoreManager.getDistanceSamples(from: activity.workout)

              await MainActor.run {
                  self.distanceSamples = distances
              }
          }
          catch let error {
              dependency.logger.log(error.localizedDescription, level: .error)
          }
      }
      
      // Get energy metadata
      Task {
          do {
              let basalEnergyBurned = try await healthStoreManager.getBasalEnergyBurnedSamples(from: activity.workout)
              let activeEnergyBurned = try await healthStoreManager.getActiveEnergyBurnedSamples(from: activity.workout)
              let avgBasalEnergyBurned = healthStoreManager.getAverage(by: basalEnergyBurned)
              let avgActiveEnergyBurned = healthStoreManager.getAverage(by: activeEnergyBurned)


              await MainActor.run {
                  self.basalEnergyBurnedSamples = basalEnergyBurned
                  self.activeEnergyBurnedSamples = activeEnergyBurned
                  self.basalEnergyBurned = avgBasalEnergyBurned
                  self.activeEnergyBurned = avgActiveEnergyBurned
              }
          }
          catch let error {
              dependency.logger.log(error.localizedDescription, level: .error)
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
