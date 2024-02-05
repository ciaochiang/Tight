//
//  TabBarItemType.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case plan
    case insight
    case setting
    
    var iconName: String {
        switch self {
        case .plan: return "checklist"
        case .insight: return "chart.bar"
        case .setting: return "gear"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .plan: return "house.fill"
        case .insight: return "chart.bar.fill"
        case .setting: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .plan: return "Checklist"
        case .insight: return "Insight"
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
