//
//  Error.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/26.
//

import Foundation

enum CustomError: Error, LocalizedError {
    case invalidInput
    case missingRequiredParameter
}
