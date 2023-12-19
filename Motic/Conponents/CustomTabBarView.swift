//
//  CustomTabBarView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

struct CustomTabBarView: View {
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItemType
    
    var body: some View {
        tabBar
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static let tabs: [TabBarItem] = [
        TabBarItem(type: .home, disabledContent: false, completion: nil),
        // TabBarItem(type: .record, disabledContent: true, completion: nil),
        TabBarItem(type: .preference, disabledContent: false, completion: nil)
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!.type))
        }
    }
}

extension CustomTabBarView {
    private func switchToTab(tab: TabBarItem) {
        selection = tab.type
    }
}

extension CustomTabBarView {
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: selection == tab.type ? tab.type.selectedIconName : tab.type.iconName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 24)
                .frame(maxWidth: 24)
            Text(tab.type.title)
                .font(.caption2)
        }
        .foregroundColor(selection == tab.type ? tab.type.accentColor : .gray)
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }
    
    private var tabBar: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                        if tab.disabledContent == false {
                            switchToTab(tab: tab)
                        }
                        
                        tab.completion?()
                    }
            }
        }
        .background(
            Color.themeStyle.theme.secondaryBackground.ignoresSafeArea(edges: .bottom)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}
