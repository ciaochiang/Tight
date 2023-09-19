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

class ProfileViewModel: ObservableObject {
  var dependency: ProfileViewModelDependency
  @Published var currentUser: BaseUser?
  @Published var isDarkModeOn: Bool = false
  
  init(dependency: ProfileViewModelDependency) {
    self.dependency = dependency
    self.currentUser = dependency.currentUser
  }
}
