//
//  ActivitySession.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/12.
//

import Foundation

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
