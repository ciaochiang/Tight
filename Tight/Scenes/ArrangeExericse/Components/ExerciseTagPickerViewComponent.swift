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
            Text(LocalizationProvider.tags.nameKey)
                .font(.subheadline)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            ExerciseTagListView(selectedTags: $arrangedExercise.tags, limit: 3)
        }
    }
}


#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self])
    return ExerciseTagPickerViewComponent(arrangedExercise: Mocks.mockArrangedExercise).modelContainer(previewContainer.container)
}
