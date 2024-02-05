//
//  InsightHomeViewModel.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/6.
//

import Foundation
import SwiftData
import SwiftUI

class InsightHomeViewModel: ObservableObject {
    private var context: ModelContext
    private var plans: [Plan] = []
    private var recordedExercises: Set<Exercise> = []
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
}
