//
//  TabBarItemType.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case plan
    case setting
    
    var iconName: String {
        switch self {
        case .plan: return "checklist"
        case .setting: return "gear"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .plan: return "house.fill"
        case .setting: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .plan: return "Checklist"
        case .setting: return "gear"
        }
    }
    
    var accentColor: Color {
        return Color.themeStyle.theme.accent
    }
    
    var backgroundColor: Color {
        return Color.themeStyle.theme.background
    }
}
