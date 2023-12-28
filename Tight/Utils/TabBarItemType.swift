//
//  TabBarItemType.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import SwiftUI

enum TabBarItemType: Hashable {
    case plan
    // case record
    case more
    
    var iconName: String {
        switch self {
        case .plan: return "checklist"
        // case .record: return "record.circle"
        case .more: return "gear"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .plan: return "house.fill"
        // case .record: return "record.circle"
        case .more: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .plan: return "Checklist"
        // case .record: return "Record"
        case .more: return "gear"
        }
    }
    
    var accentColor: Color {
        return Color.themeStyle.theme.accent
    }
    
    var backgroundColor: Color {
        return Color.themeStyle.theme.background
    }
}
