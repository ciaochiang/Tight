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
    let logger: CustomLogger = CustomLogger()
    
    @AppStorage("UserType") var userType: String?
    @Published var currentUser: BaseUser?
    @Published var isLoggedIn: Bool = false

    init() {
        // try login
        if let userId = UserDefaults.standard.string(forKey: "UserId") {
            login(userId: userId)
        }
    }
    
    @discardableResult func login(userId: String) -> Bool {
        guard let userData = UserDefaults.standard.data(forKey: userId),
              let user = try? JSONDecoder().decode(AppleUser.self, from: userData)
        else { return false }
        
        currentUser = user
        isLoggedIn = true
        return true
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
                // try login
                guard login(userId: appleIdCredential.user) == false else { return }
                
                // create user
                guard let newUser = AppleUser(credential: appleIdCredential),
                      let userData = try? JSONEncoder().encode(newUser) else { return }
                
                UserDefaults.standard.setValue("apple", forKey: "UserType")
                UserDefaults.standard.setValue(newUser.userId, forKey: "UserId")
                UserDefaults.standard.setValue(userData, forKey: newUser.userId)
                logger.log("Save apple user: \(newUser)")
                
                // login
                currentUser = newUser
            default:
                logger.log("\(auth.credential)")
            }
        case .failure(let error):
            logger.log("Error: \(error.localizedDescription)", level: .error)
        }
    }
}
