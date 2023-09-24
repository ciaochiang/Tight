//
//  AccountManager.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/17.
//

import SwiftUI
import AuthenticationServices

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
      retreiveCurrentUser()
    default: break
    }
  }
  
  func retreiveCurrentUser() {
    guard let appleUserData = UserDefaults.standard.data(forKey: "User"),
          let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData)
    else { return }
    
    currentUser = appleUser
  }
  
  func logout() {
    // Clean user data
    currentUser = nil
    isLoggedIn = false
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
          UserDefaults.standard.setValue(appleUserData, forKey: appleUser.userId)
          logger.log("Save apple user: \(appleUser)", level: .info)
        } else {
          guard let appleUserData = UserDefaults.standard.data(forKey: "User"),
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
