//
//  BaseUser.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/19.
//

import Foundation

protocol BaseUser: Codable {
  var userId: String { get }
  var firstName: String { get }
  var lastName: String { get }
  var email: String { get }
  var age: Int? { set get }
}
