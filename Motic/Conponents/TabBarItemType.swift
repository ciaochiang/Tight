//
//  TabBarItem.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case home
    case record
    case preference
    
    var iconName: String {
        switch self {
        case .home: return "circle.hexagongrid.fill"
        case .record: return "record.circle"
        case .preference: return "list.dash"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .record: return "Record"
        case .preference: return "Profile"
        }
    }
    
    var accentColor: Color {
        return Color.themeStyle.theme.blue
    }
    
    var backgroundColor: Color {
        return Color.themeStyle.theme.background
    }
}
