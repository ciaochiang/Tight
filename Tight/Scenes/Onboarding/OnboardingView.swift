//
//  OnboardingView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import SwiftUI

struct OnboardingView: View {
    // Onboarding states:
    /*
     0 - Welcome screen
     1 - Notification
     2 - Done
     */
    @StateObject var viewModel: OnboardingViewModel
    let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing),
                                                removal: .move(edge: .leading))
    
    init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
      
    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentIndex) {
                OnboadingWelcomView().tag(0)
                OnboardingNotificationView().tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            footerSection
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .background(Color.themeStyle.theme.white)
        .onChange(of: viewModel.currentIndex) { oldValue, newValue in
            switch newValue {
            case 0: viewModel.state = .welcome
            case 1: viewModel.state = .requestNotificationPermission
            default: break
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = OnboardingViewModel(isOnboardingCompleted: .constant(false))
        OnboardingView(viewModel: viewModel)
    }
}

// MARK: COMPONENTS
extension OnboardingView {
    private var footerSection: some View {
        HStack {
            // Pagination
            indicators
            
            Spacer()
            
            // Next button
            Button {
                handleNextButtonPressed()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeStyle.theme.white)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 48, height: 48)
            .background(Color.themeStyle.theme.black)
            .cornerRadius(24)
        }
    }
    
    private var indicators: some View {
        HStack(spacing: 15) {
            ForEach(0..<2) { index in
                Capsule().fill(Color.black)
                    .frame(width:  viewModel.currentIndex == index ? 20 : 7, height: 7)
            }
        }
    }
}


// MARK: FUNCTIONS
extension OnboardingView {
  func handleNextButtonPressed() {
      viewModel.handleButtonAction(with: viewModel.state)
  }
}


struct OnboadingWelcomView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizationProvider.appName.nameKey)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
            
            Text(LocalizationProvider.onboardingWelcomeDescription.nameKey)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.black)
        }
        .padding(32)
    }
}

struct OnboardingNotificationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(LocalizationProvider.allowReceive.nameKey)
                    .textCase(.lowercase)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
                
                Text(LocalizationProvider.notification.nameKey)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.themeStyle.theme.accent)
            }
            
            Text(LocalizationProvider.onboardingNotificationDescription.nameKey)
                .font(.body)
                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                .frame(maxWidth: 360, alignment: .leading)
        }
        .padding(32)
    }
}
