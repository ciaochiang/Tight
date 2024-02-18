//
//  TimerView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/20.
//

import SwiftUI

struct TimerView: View {
    var startTime: Date
    var restStartTime: Date? = nil
    var restInterval: TimeInterval? = nil
    var isCountDown: Bool = false
    var fontWeight: Font.Weight = .bold
    
    var body: some View {
        if isCountDown, let restStartTime = restStartTime, let restInterval = restInterval {
            Text(timerInterval: restStartTime...restStartTime.addingTimeInterval(restInterval), countsDown: true)
                .fontWeight(fontWeight)
                .minimumScaleFactor(0.8)
                .foregroundColor(Color.themeStyle.theme.secondaryAccent)
                .contentTransition(.numericText(countsDown: true))
        }
        else {
            Text(startTime, style: .timer)
                .fontWeight(fontWeight)
                .minimumScaleFactor(0.8)
                .foregroundColor(Color.themeStyle.theme.accent)
                .contentTransition(.numericText())
        }
    }
}

#Preview("elapsed") {
    TimerView(startTime: .now)
}

#Preview("countdown") {
    TimerView(startTime: .now, restStartTime: .now, restInterval: 180, isCountDown: true)
}
