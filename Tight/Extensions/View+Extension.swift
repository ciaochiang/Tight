//
//  View+Extension.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

/// Custom View Extensions
extension View {
    ///  Custom Spacers
    @ViewBuilder
    func horizontalSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    
    @ViewBuilder
    func veriticalSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    
    
    /// checking Two dates are same
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
