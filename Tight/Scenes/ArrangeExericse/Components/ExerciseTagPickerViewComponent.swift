//
//  ExerciseTagPickerViewComponent.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/29.
//

import SwiftUI

struct ExerciseTagPickerViewComponent: View {
    var title: LocalizedStringKey
    @Binding var tags: [ExerciseTag]
    @Bindable var arrangedExercise: ArrangedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            ExerciseTagListView(tags: $tags, selectedTags: $arrangedExercise.tags, limit: 3)
        }
    }
}


#Preview {
    let previewContainer = PreviewContainer([ArrangedExercise.self])
    return ExerciseTagPickerViewComponent(title: LocalizationProvider.tags.nameKey,
                                          tags: .constant([.abRoller]),
                                          arrangedExercise: Mocks.mockArrangedExercise).modelContainer(previewContainer.container)
}
