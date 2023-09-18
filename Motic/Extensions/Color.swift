//
//  Color.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/18.
//

import Foundation
import SwiftUI

extension Color {
  static let themeStyle: ColorThemeStyle = .main
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
  let primary = Color("PrimaryColor")
  let inversePrimary = Color("InversePrimaryColor")
  let white = Color.white
  let black = Color.black
  let accent = Color("AccentColor")
  let background = Color("BackgroundColor")
  let secondaryBackground = Color("SecondaryBackgroundColor")
  let green = Color("GreenColor")
  let red = Color("RedColor")
  let blue = Color("BlueColor")
  let secondaryTextColor = Color("SecondaryTextColor")
}
