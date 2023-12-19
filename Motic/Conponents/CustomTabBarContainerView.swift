//
//  CustomTabBarContainerView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

struct CustomTabBarContainerView<Content: View>: View {
    let content: Content
    @Binding var selection: TabBarItemType
    @State private var tabs: [TabBarItem] = []
    
    init(selection: Binding<TabBarItemType>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                content.ignoresSafeArea()
                CustomTabBarView(tabs: tabs, selection: $selection)
            }
            .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
                self.tabs = value
            }
        }
    }
}

struct CustomTabBarContainerView_Previews: PreviewProvider {
    static let tabs: [TabBarItemType] = [
        .home, .preference
    ]
    
    static var previews: some View {
        CustomTabBarContainerView(selection: .constant(tabs.first!)) {
            Color.red
        }
    }
}
