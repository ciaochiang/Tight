//
//  TrainingSessionState.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/22.
//

import Foundation

enum TTSessionState: Int, Codable {
    case notStarted = 0
    case training = 1
    case resting = 2
}
