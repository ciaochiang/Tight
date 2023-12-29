//
//  ExerciseTagPickerViewComponent.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/29.
//

import SwiftUI

struct ExerciseTagPickerViewComponent: View {
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            ExerciseTagListView(selectedTags: $arrangedExercise.tags, limit: 3)
        }
    }
}


#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self])
    return ExerciseTagPickerViewComponent(arrangedExercise: .init(exercise: .none, repetitions: 0, sets: 0, weight: 0, durationOfSet: 0, restIntevals: 0, order: 0, tags: [], isCompleted: false)).modelContainer(previewContainer.container)
}
