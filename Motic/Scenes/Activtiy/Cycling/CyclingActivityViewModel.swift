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
  let id: String = UUID().uuidString
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
  @Published var workoutType: WorkoutActivityType
  @Published var duraiton: TimeInterval
  @Published var totalDistanceMeters: Double
  @Published var avgHeartRate: Double = 0
  @Published var avgSpeedPerHour: Double = 0
  @Published var avgMETs: Double?
  @Published var heartRateSamples: [ChartData<Double>] = []
  @Published var weatherTemperatureCelsius: Double?
  @Published var weatherHumidity: Double?
  @Published var timezone: TimeZone?
  
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
    self.timezone = healthStoreManager.getTimezone(from: workout)
    self.totalDistanceMeters = healthStoreManager.getTotalDistanceMeters(workout: workout)
    self.workoutType = WorkoutActivityType(activityType: workout.workoutActivityType)

    // After initialization
    self.avgSpeedPerHour = healthStoreManager.getAvgSpeedPerHour(duration: self.duraiton,
                                                                 totalDistanceMeters: self.totalDistanceMeters)
    
    // Get all heart rate samples
    healthStoreManager.getAllHeartRateSamples(workout: workout) { [weak self] heartRates in
      DispatchQueue.main.async {
        self?.heartRateSamples = heartRates
      }
    }
    
    // Get avg. heart rate
    healthStoreManager.getAvgHeartRate(from: workout) { heartRate, _ in
      DispatchQueue.main.async {
        self.avgHeartRate = heartRate
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
