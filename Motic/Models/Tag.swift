//
//  Tag.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/27.
//

import SwiftUI
import SwiftData

@Model
class Tag: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var colourR: Double
    var colourG: Double
    var colourB: Double
    var colourA: Double
    var isInitial: Bool
    
    init(id: UUID = .init(),
         name: String, 
         colourR: Double,
         colourG: Double,
         colourB: Double,
         colourA: Double,
         isInitial: Bool = false) {
        self.id = id
        self.name = name
        self.colourR = colourR
        self.colourG = colourG
        self.colourB = colourB
        self.colourA = colourA
        self.isInitial = isInitial
    }
}
