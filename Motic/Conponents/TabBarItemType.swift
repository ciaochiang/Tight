//
//  TabBarItem.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/27.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case home
    // case record
    case preference
    
    var iconName: String {
        switch self {
        case .home: return "house"
        // case .record: return "record.circle"
        case .preference: return "slider.horizontal.below.square.filled.and.square"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        // case .record: return "record.circle"
        case .preference: return "slider.horizontal.below.square.and.square.filled"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        // case .record: return "Record"
        case .preference: return "Preference"
        }
    }
    
    var accentColor: Color {
        return Color.themeStyle.theme.accent
    }
    
    var backgroundColor: Color {
        return Color.themeStyle.theme.background
    }
}
