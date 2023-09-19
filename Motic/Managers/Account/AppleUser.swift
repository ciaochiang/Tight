//
//  AppleUser.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/19.
//

import Foundation
import AuthenticationServices

struct AppleUser: BaseUser {
  let userId: String
  let firstName: String
  let lastName: String
  let email: String
  
  init?(credential: ASAuthorizationAppleIDCredential) {
    guard let firstName = credential.fullName?.givenName,
          let lastName = credential.fullName?.familyName,
          let email = credential.email
    else { return nil }
    
    self.userId = credential.user
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}
