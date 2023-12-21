//
//  ScheduleExerciseView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/21.
//

import SwiftUI

struct ScheduleExerciseView: View {
    /// View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseName: String = ""
    @State private var isFocused: FocusState<Bool> = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
           
            VStack(alignment: .leading, spacing: 8) {
                Text("Exercise Name")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Do something", text: $exerciseName)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            }
            .horizontalSpacing(.leading)
            
            Button(action: {}) {
                Text("Add Exercise")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .horizontalSpacing(.center)
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .background(Color.themeStyle.theme.accent, in: .rect(cornerRadius: 10))
            }
            .disabled(exerciseName == "")
            .opacity(exerciseName == "" ? 0.5 : 1)
        }
        .padding()
        .veriticalSpacing(.bottom)
        .onAppear(perform: {
            
        })
    }
}

#Preview {
    ScheduleExerciseView()
        .veriticalSpacing(.bottom)
}
