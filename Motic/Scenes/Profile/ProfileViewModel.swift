//
//  ProfileViewModel.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/19.
//

import SwiftUI

protocol ProfileViewModelDependency {
  var logger: Logger { get }
  var currentUser: BaseUser? { get }
}

struct ProfileViewModelDependencyImp: ProfileViewModelDependency {
  var logger: Logger
  var currentUser: BaseUser?
  
  init(logger: Logger, currentUser: BaseUser?) {
    self.logger = logger
    self.currentUser = currentUser
  }
}

struct Profile {
  var fullName: String
  var thumbnailURL: URL?
  var sections: [ProfileSection]
}

struct ProfileSection: Hashable {
  var type: ProfileSectionType
  var items: [ProfileSectionItem]
}

struct ProfileSectionItem: Hashable {
  var type: ProfileSectionItemType
  var value: String
}

enum ProfileSectionType {
  case account
  case appearance

  var title: String {
    switch self {
    case .account: return "Account"
    case .appearance: return "Appearance"
    }
  }
}

enum ProfileSectionItemType {
  
  // Account
  case username
  case email
  case birthday
  case chanagePassword
  
  // Appearance
  case darkMode

  
  var title: String {
    switch self {
    // Account
    case .username: return "Username"
    case .email: return "Mail"
    case .birthday: return "Birthday"
    case .chanagePassword: return "Change Password"

    // Appearance
    case .darkMode: return "Dark Mode"
    }
  }
}

class ProfileViewModel: ObservableObject {
  var dependency: ProfileViewModelDependency
  @Published var currentUser: BaseUser?
  @Published var isDarkModeOn: Bool = false
  @Published var profile: Profile
  
  init(dependency: ProfileViewModelDependency) {
    self.dependency = dependency
    self.currentUser = dependency.currentUser
    
//    let username = ProfileSectionItem(type: .username, value: "")
    let mail = ProfileSectionItem(type: .email, value: "\(dependency.currentUser?.email ?? "")")
    let accountSection = ProfileSection(type: .account, items: [mail])
    
    let darkMode = ProfileSectionItem(type: .darkMode, value: "Dark")
    let appearanceSection = ProfileSection(type: .appearance, items: [darkMode])
    
    let profile = Profile(fullName: "\(dependency.currentUser?.firstName ?? "") \(dependency.currentUser?.lastName ?? "")", sections: [accountSection, appearanceSection])
    self.profile = profile
  }
}
