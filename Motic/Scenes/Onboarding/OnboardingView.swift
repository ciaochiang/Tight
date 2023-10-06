//
//  OnboardingView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    // Onboarding states:
    /*
     0 - Welcome screen
     1 - Authorize healthkit
     2 - Location
     3 - Notification
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
                OnboardingHealthKitView().tag(1)
                OnboardingNotificationView().tag(2)
                OnboardingLocationView().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            footerSection
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .background(Color.themeStyle.theme.white)
      
//      VStack {
        // Content
//        authorizeHealthKitSection
        
//        if viewModel.state == .welcome {
//          SignInWithAppleButton(.continue,
//                                onRequest: AccountManager.shared.requestAppleSignIn) { result in
//            AccountManager.shared.handleAppleSignIn(result)
//            self.handleNextButtonPressed()
//          }
//                                .signInWithAppleButtonStyle(.white)
//                                .frame(height: 48)
//                                .frame(maxWidth: .infinity)
//                                .cornerRadius(8)
//        }
//      }
//      .padding(30)
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
            ForEach(0..<4) { index in
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
            Text("Oasis")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
            
            Text("your best fitness assitant")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.black)
        }
        .padding(32)
    }
}

struct OnboardingHealthKitView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("connect")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            
            Text("Your Health")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
            
            Text("We will save your workout data to the HealthKit to give you a consolidated view of your fitness activity and to help you track your progress over time")
                .font(.body)
                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                .frame(maxWidth: 360, alignment: .leading)
        }
        .padding(32)
    }
}

struct OnboardingNotificationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("receive")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            
            Text("Notification")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
            
            Text("Allow notifications to stay updated on your workout progress, receive motivational reminders, get informed about new fitness challenges, and never miss a training session.")
                .font(.body)
                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                .frame(maxWidth: 360, alignment: .leading)
        }
        .padding(32)
    }
}

struct OnboardingLocationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("record")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.secondaryTextColor)
            
            Text("Your Paths")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.themeStyle.theme.accent)
            
            Text("To accurately track your outdoor workouts like running or cycling, we continuously monitor your location, even when the app is in the background.")
                .font(.body)
                .foregroundColor(.themeStyle.theme.secondaryTextColor)
                .frame(maxWidth: 360, alignment: .leading)
        }
        .padding(32)
    }
}
