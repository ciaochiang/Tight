//
//  LinearProgressView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/20.
//

import SwiftUI

struct LinearProgressView: View {
    var progress: Double
    
    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(.linear)
            .background(Color.white.opacity(0.7))
            .foregroundStyle(Color.themeStyle.theme.accent)
            .animation(.easeInOut, value: progress)
    }
}

#Preview {
    LinearProgressView(progress: 10)
}
