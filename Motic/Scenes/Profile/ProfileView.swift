//
//  ProfileView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/19.
//

import SwiftUI

struct ProfileView: View {
  @StateObject var viewModel: ProfileViewModel
  @StateObject var preferenceManager: PreferenceManager
  
  init(viewModel: ProfileViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _preferenceManager = StateObject(wrappedValue: viewModel.dependency.preferenceManager)
  }
  
  var body: some View {
    VStack(spacing: 32) {
      HStack(spacing: 16) {
        Text(viewModel.profile.fullName)
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.themeStyle.theme.primary)
        Spacer()
        Image(systemName: "person")
          .frame(width: 48, height: 48)
          .foregroundColor(.themeStyle.theme.inversePrimary)
          .background(Color.themeStyle.theme.primary)
          .cornerRadius(30)
      }
      .preferredColorScheme(preferenceManager.colorScheme)
      .frame(maxWidth: .infinity)
      
      VStack(spacing: 8) {
        ForEach(viewModel.profile.sections) { section in
          VStack {
            HStack {
              Text(section.type.title)
                .font(.headline)
                .foregroundColor(.themeStyle.theme.primary)
              Spacer()
            }
            .frame(height: 40)
            
            ForEach(section.items) { item in
              HStack(alignment: .bottom) {
                Text(item.type.title)
                  .font(.subheadline)
                  .foregroundColor(.themeStyle.theme.primary)
                Spacer()
                
                switch item.type {
                case .darkMode:
                  Toggle("", isOn: $viewModel.isDarkModeOn)
                    .onChange(of: viewModel.isDarkModeOn) { value in
                      viewModel.toggleDarkMode(isOn: value)
                      print("Dark mode change: \(value)")
                    }
                default:
                  Text(item.value)
                    .font(.caption)
                    .foregroundColor(.themeStyle.theme.secondaryTextColor)
                }
              }
              .frame(height: 40)
            }
          }
        }
      }
      .frame(maxWidth: .infinity)
      .preferredColorScheme(preferenceManager.colorScheme)
      .background(Color.themeStyle.theme.background)
      Spacer()
      Button("Log Out") {
        // Log Out and lead user to onboarding page
      }
      .frame(height: 60)
      .frame(maxWidth: .infinity)
      .preferredColorScheme(preferenceManager.colorScheme)
      .foregroundColor(.themeStyle.theme.white)
      .background(Color.themeStyle.theme.black)
      .cornerRadius(16)
    }
    .padding(30)
    .frame(maxHeight: .infinity)
    .preferredColorScheme(preferenceManager.colorScheme)
    .background(Color.themeStyle.theme.background)
  }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
      let logger = Logger(configuration: AppConfiguration.loggerConfig)
      let dependency = ProfileViewModelDependencyImp(preferenceManager: PreferenceManager.shared,
                                                     logger: logger,
                                                     currentUser: AccountManager.shared.currentUser)
      let viewModel = ProfileViewModel(dependency: dependency)
      ProfileView(viewModel: viewModel)
    }
}
