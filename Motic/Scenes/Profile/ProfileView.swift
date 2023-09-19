//
//  ProfileView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/19.
//

import SwiftUI

struct ProfileView: View {
  @StateObject var viewModel: ProfileViewModel
  
  init() {
    let logger = Logger(configuration: AppConfiguration.loggerConfig)
    let dependency = ProfileViewModelDependencyImp(logger: logger,
                                                   currentUser: AccountManager.shared.currentUser)
    _viewModel = StateObject(wrappedValue: ProfileViewModel(dependency: dependency))
    
  }
  
    var body: some View {
      VStack(spacing: 32) {
        HStack(spacing: 16) {
          Image(systemName: "person")
            .frame(width: 60, height: 60)
            .foregroundColor(.themeStyle.theme.primary)
            .background(Color.white)
            .cornerRadius(30)
          Text("Ciao Chiang")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.themeStyle.theme.primary)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        VStack(spacing: 32) {
          ForEach(0..<4) { int in
            HStack {
              Text("Item")
                .font(.title2)
              Spacer()
              Toggle("", isOn: $viewModel.isDarkModeOn)
            }
          }
        }
        .frame(maxWidth: .infinity)
        .background(Color.themeStyle.theme.background)
        Spacer()
        Button("Log Out") {
          // Log Out and lead user to onboarding page
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .foregroundColor(.themeStyle.theme.white)
        .background(Color.themeStyle.theme.black)
        .cornerRadius(16)
      }
      .padding(30)
      .frame(maxHeight: .infinity)
      .background(Color.themeStyle.theme.background)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
