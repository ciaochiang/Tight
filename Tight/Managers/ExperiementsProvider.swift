//
//  ExperiementsProvider.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/11/16.
//

import Foundation
import GrowthBook
import SwiftUI

class ExperiementsProvider: ObservableObject {
    private var gb: GrowthBookSDK
    @Published var isRecordingEnabled: Bool = false
    
    init() {
        self.gb = GrowthBookBuilder(
            url: "https://cdn.growthbook.io/api/features/sdk-SRBMqVwqlecFFZw",
            attributes: [
                "id": "test"
            ], trackingCallback: { experiment, experimentResult in
                // TODO: Use your real analytics tracking system
//                print("Viewed Experiment")
//                print("Experiment Id: ", experiment.key)
//                print("Variation Id: ", experimentResult.variationId)
            }
        ).initializer()
        
        retrieveFeatureFlags()
    }
    
    
    func retrieveFeatureFlags() {
        isRecordingEnabled = gb.isOn(feature: "is_recording_enabled")
    }
}
