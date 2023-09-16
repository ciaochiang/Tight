//
//  ContentView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/14.
//

import SwiftUI
import HealthKit

struct ContentView: View {
  let healthStore = HKHealthStore()
  @StateObject private var messageViewModel = MessageViewModel()
  
    var body: some View {
      VStack(alignment: .leading) {
        Spacer()
        Text("Zone 1")
          .padding(.bottom, 8)
          .foregroundColor(.green)
          .font(Font.system(size: 24, weight: .semibold))
        
        Text("Hear Rate")
          .padding(.bottom, 24)
          .foregroundColor(.yellow)
          .font(Font.system(size: 24, weight: .semibold))
        
        Button("Start", action: {
          // do nothing
        })
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.white)
        .background(Color.blue)
        .cornerRadius(4)
      }
      .padding(.all, 16)
    }
  
  func getHealthKitData() {
    if HKHealthStore.isHealthDataAvailable() {
            let readTypes: Set<HKObjectType> = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]

            healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if success {
                    // You have authorization, now you can fetch heart rate data
                    self.fetchHeartRateData()
                } else {
                    if let error = error {
                        print("HealthKit authorization request failed with error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("HealthKit data is not available on this device.")
        }
  }
  
  func fetchHeartRateData() {
//      // Create a heart rate type
//      if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
//          // Set up a query to retrieve the most recent heart rate sample
//          let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 20, sortDescriptors: nil) { (query, results, error) in
//
//              if let heartRateData = results?.first as? HKQuantitySample {
//                  // Extract heart rate value and unit
//                  let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
//                  let heartRate = heartRateData.quantity.doubleValue(for: heartRateUnit)
//
//                  // Print or use the heart rate data as needed
//                  print("Heart Rate: \(heartRate)")
//              } else {
//                  if let error = error {
//                      print("Error fetching heart rate data: \(error.localizedDescription)")
//                  }
//              }
//          }
//
//          // Execute the query
//          healthStore.execute(query)
//      }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!

    var startDateComponents = DateComponents()
    startDateComponents.year = 2023
    startDateComponents.month = 9
    startDateComponents.day = 12
    
    var endDateComponents = DateComponents()
    endDateComponents.year = 2023
    endDateComponents.month = 9
    endDateComponents.day = 14
    
    let dateFormmater = DateFormatter()
    dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormmater.timeZone = TimeZone.current
    
    // Create a heart rate type
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            // Create a predicate to filter samples within the specified date range
          let predicate = HKQuery.predicateForSamples(withStart: calendar.date(from: startDateComponents),
                                                      end: calendar.date(from: endDateComponents),
                                                      options: .strictStartDate)

            // Set up a query to retrieve heart rate samples within the date range
            let query = HKSampleQuery(sampleType: heartRateType,
                                      predicate: predicate,
                                      limit: Int(HKObjectQueryNoLimit),
                                      sortDescriptors: nil) { (query, results, error) in
                if let heartRateData = results as? [HKQuantitySample] {
                    // Process the heart rate data as needed
                    for data in heartRateData {
                        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                        let heartRate = data.quantity.doubleValue(for: heartRateUnit)
                      let sampleDate = dateFormmater.string(from: data.startDate)
                        print("Heart Rate: \(heartRate) BPM, Date: \(sampleDate)")
                    }
                } else {
                    if let error = error {
                        print("Error fetching heart rate data: \(error.localizedDescription)")
                    }
                }
            }

            // Execute the query
          healthStore.execute(query)
        }
  }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
