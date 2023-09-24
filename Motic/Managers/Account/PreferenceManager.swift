//
//  PreferenceManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/24.
//

import SwiftUI

class PreferenceManager: ObservableObject {
  static let shared = PreferenceManager()
  
  @Published var colorScheme: ColorScheme
  
  init() {
    if let value = UserDefaults.standard.value(forKey: "PERF_IS_DARK_MODE_ON"),
        let isDarkModeOnValue = value as? Bool {
      _colorScheme = Published(wrappedValue: isDarkModeOnValue == true ? ColorScheme.dark : ColorScheme.light)
    } else if #available(iOS 12, *) {
      let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
      _colorScheme = Published(wrappedValue: userInterfaceStyle == .dark ? ColorScheme.dark : ColorScheme.light)
    } else {
      _colorScheme = Published(wrappedValue: ColorScheme.light)
    }
  }
  
  func toggleDarkMode(isOn: Bool) {
    colorScheme = isOn ? .dark : .light
    
    UserDefaults.standard.setValue(isOn, forKey: "PERF_IS_DARK_MODE_ON")
  }
}
