//
//  PreviewContainer.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/22.
//

import Foundation
import SwiftData

struct PreviewContainer {
    let container: ModelContainer
    
    init(_ types: [any PersistentModel.Type], isStoredInMemoryOnly: Bool = true) {
        let schema = Schema(types)
        let configuation = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.container = try! ModelContainer(for: schema, configurations: configuation)
    }
    
    func add(items: [any PersistentModel]) {
        Task { @MainActor in
            items.forEach {
                container.mainContext.insert($0)
            }
        }

    }
}
