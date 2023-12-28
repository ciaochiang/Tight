//
//  OffsetKey.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/20.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
