//
//  AccountManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import SwiftUI
import AuthenticationServices

protocol BaseUser: Codable {
  var userId: String { get }
  var firstName: String { get }
  var lastName: String { get }
  var email: String { get }
}

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

class AccountManager: ObservableObject {
  static let shared = AccountManager()
  let logger: Logger = Logger(configuration: AppConfiguration.loggerConfig)
  @AppStorage("UserType") var userType: String?
  @Published var currentUser: BaseUser?
  @Published var isLoggedIn: Bool = false

  init() {
    switch userType {
    case "apple":
      // retrieve apple user data
      isLoggedIn = true
      
      if let appleUserData = UserDefaults.standard.data(forKey: "User"),
         let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) {
        currentUser = appleUser
      }
      else { return }
    default: break
    }
  }
}

// MARK: SignInWithApple Functions
extension AccountManager {
  func requestAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.fullName, .email]
  }
  
  func handleAppleSignIn(_ authResult: Result<ASAuthorization, Error>) {
    switch authResult {
    case .success(let auth):
      switch auth.credential {
      case let appleIdCredential as ASAuthorizationAppleIDCredential:
        if let appleUser = AppleUser(credential: appleIdCredential),
            let appleUserData = try? JSONEncoder().encode(appleUser) {
          UserDefaults.standard.setValue("apple", forKey: "UserType")
          UserDefaults.standard.setValue(appleUserData, forKey: "User")
          logger.log("Save apple user: \(appleUser)", level: .info)
        } else {
          guard let appleUserData = UserDefaults.standard.data(forKey: appleIdCredential.user),
                let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData)
          else { return }
          
          currentUser = appleUser
        }
      default:
        logger.log("\(auth.credential)", level: .info)
      }
    case .failure(let error):
      logger.log("Error: \(error.localizedDescription)", level: .error)
    }
  }
}
