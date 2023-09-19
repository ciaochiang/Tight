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

struct ProfileSectionItem: Hashable {
  var title: String
}

enum ProfileSection: Hashable {
  case account([AccountSectionItem])
  case preferences([PreferencesSectionItem])
  case appearance([AppearanceSectionItem])

  var title: String {
    switch self {
    case .account: return "Account"
    case .preferences: return "Preferences"
    case .appearance: return "Appearance"
    }
  }
  
  var items: [ProfileSectionItem] {
    switch self {
    case .account(let sectionItems): return sectionItems.map { ProfileSectionItem(title: $0.title) }
    case .preferences(let sectionItems): return sectionItems.map { ProfileSectionItem(title: $0.title) }
    case .appearance(let sectionItems): return sectionItems.map { ProfileSectionItem(title: $0.title) }
    }
  }
  
  static let allCases: [ProfileSection] = [
    .account(AccountSectionItem.allCases),
    .preferences(PreferencesSectionItem.allCases),
    .appearance(AppearanceSectionItem.allCases)
  ]
}

enum AccountSectionItem: CaseIterable {
  case username
  case email
  case birthday
  case chanagePassword
  
  var title: String {
    switch self {
    case .username: return "Username"
    case .email: return "Mail"
    case .birthday: return "Birthday"
    case .chanagePassword: return "Change Password"
    }
  }
}

enum PreferencesSectionItem: CaseIterable {
  case test
  var title: String {
    switch self {
    case .test: return "Test"
    }
  }
}

enum AppearanceSectionItem: CaseIterable {
  case darkMode
  
  var title: String {
    switch self {
    case .darkMode: return "Dark Mode"
    }
  }
}

class ProfileViewModel: ObservableObject {
  var dependency: ProfileViewModelDependency
  @Published var currentUser: BaseUser?
  @Published var isDarkModeOn: Bool = false
  @Published var sections: [ProfileSection]
  
  init(dependency: ProfileViewModelDependency) {
    self.dependency = dependency
    self.currentUser = dependency.currentUser
    self.sections = ProfileSection.allCases
  }
}
