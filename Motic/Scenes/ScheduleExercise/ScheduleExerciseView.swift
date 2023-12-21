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
    @State private var selectedExercise: Exercise = .none
    @State private var repetitions: Double = 10
    @State private var sets: Double = 3
    @State private var isFocused: FocusState<Bool> = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
           
            VStack(alignment: .leading, spacing: 8) {
                Text("Exercise")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text(selectedExercise.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            }
            .horizontalSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Repetitions")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack(alignment: .center, spacing: 8) {
                    Text(String(format: "%.0f", repetitions))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    
                    Slider(value: $repetitions, in: 1...20, step: 1.0)
                        .accentColor(Color.themeStyle.theme.accent)
                }
            }
            .horizontalSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Sets")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack(alignment: .center, spacing: 8) {
                    Text(String(format: "%.0f", sets))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    
                    Slider(value: $sets, in: 1...6, step: 1.0)
                        .accentColor(Color.themeStyle.theme.accent)
                }
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
            .disabled(selectedExercise == .none)
            .opacity(selectedExercise == .none ? 0.5 : 1)
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

