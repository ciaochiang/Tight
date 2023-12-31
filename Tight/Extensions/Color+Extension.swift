//
//  Color.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/18.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    static let themeStyle: ColorThemeStyle = .main
    
    var components: (r: Double, g: Double, b: Double, a: Double) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else { return (0,0,0,0) }
        
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

enum ColorThemeStyle {
  case main
  
  var theme: ColorTheme {
    switch self {
    case .main: return ColorTheme()
    }
  }
}

struct ColorTheme {
    let primary = Color("TightPrimaryColor")
    let inversePrimary = Color("InversePrimaryColor")
    let white = Color.white
    let black = Color.black
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let secondaryAccent = Color("SecondaryAccentColor")
    let primaryTextColor = Color("PrimaryTextColor")
    let secondaryTextColor = Color("SecondaryTextColor")
}
