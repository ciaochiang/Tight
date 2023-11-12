//
//  ElaspsedTime.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/12.
//

import Foundation

struct ElapsedTime: Identifiable {
    let id: String = UUID().uuidString
    var activityId: String
    var status: ElapsedTimeStatus
    var timestamp: Date
}
