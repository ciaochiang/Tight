//
//  TabBarItemType.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case plan
    case trend
    case setting
    
    var iconName: String {
        switch self {
        case .plan: return "list.dash"
        case .trend: return "chart.line.uptrend.xyaxis"
        case .setting: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .plan: return "Checklist"
        case .trend: return "Insight"
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
