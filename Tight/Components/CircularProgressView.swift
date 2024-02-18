//
//  CircularProgressView.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/2/18.
//

import SwiftUI

struct CircularProgressView: View {
    var content: String
    var progress: Double
    var font: Font = .title3
    var fontWeight: Font.Weight = .semibold
    var lineWidth: CGFloat = 1
    var width: CGFloat = 44
    var height: CGFloat = 44
    
    var body: some View {
        Text(content)
            .foregroundStyle(Color.themeStyle.theme.primary.opacity(0.8))
            .font(font)
            .fontWeight(fontWeight)
            .overlay {
                ZStack {
                    Circle()
                        .stroke(
                            Color.themeStyle.theme.primary.opacity(0.3),
                            lineWidth: lineWidth
                        )
                        .frame(width: width, height: height)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.themeStyle.theme.accent,
                            lineWidth: lineWidth
                        )
                        .frame(width: width, height: height)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                }
            }
    }
}

#Preview {
    let content: String = "1"
    let progress: Double = 30
    return CircularProgressView(content: content, progress: progress)
}


