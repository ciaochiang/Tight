//
//  TabBarItemPreferenceKey.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

typealias CompletionClosure = () -> Void
struct TabBarItem: Equatable, Hashable {
    let id = UUID()
    let type: TabBarItemType
    let disabledContent: Bool
    let completion: CompletionClosure?
    
    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
}

struct TabBarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [TabBarItem] = []
    
    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
        value += nextValue()
    }
}

struct TabBarItemViewModifier: ViewModifier {
    let type: TabBarItemType
    @Binding var selection: TabBarItemType
    let disableContent: Bool
    let completion: CompletionClosure?
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == type ? 1.0 : 0.0)
            .preference(key: TabBarItemsPreferenceKey.self, value: [
                TabBarItem(type: type,
                           disabledContent: disableContent,
                           completion: completion)
            ])
    }
}

extension View {
    func tabBarItem(type: TabBarItemType,
                    selection: Binding<TabBarItemType>,
                    disableContent: Bool = false,
                    completion: CompletionClosure? = nil) -> some View {
        self.modifier(
            TabBarItemViewModifier(type: type,
                                   selection: selection,
                                   disableContent: disableContent,
                                   completion: completion)
        )
    }
}
