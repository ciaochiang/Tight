//
//  Onboarding.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/9/16.
//

import SwiftUI

struct Onboarding: View {
  // Onboarding states:
  /*
   0 - Welcome screen
   1 - Authorize healthkit
   2 - Location
   3 - Notification
   2 - Done
   */
  @StateObject var viewModel: OnboardingViewModel = OnboardingViewModel()
  let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing),
                                              removal: .move(edge: .leading))
  
  var body: some View {
    ZStack {
      // Content
      ZStack {
        switch viewModel.state {
        case .welcome: welcomeSection.transition(transition)
        case .requestHealthKitPermission: authorizeHealthKitSection.transition(transition)
        case .requestLocationPermission: locationSeciton.transition(transition)
        case .requestNotificationPermission: notificationSection.transition(transition)
        case .done: doneSection.transition(transition)
        }
      }
      .drawingGroup()
      
      
      // Button
      VStack {
        Spacer()
        bottomButton
      }
      .padding(30)
    }
    .background(
      Color.purple.ignoresSafeArea()
    )
  }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}

// MARK: COMPONENTS
extension Onboarding {
  private var bottomButton: some View {
    Text(viewModel.state.buttonTitle)
      .font(.headline)
      .foregroundColor(.purple)
      .frame(height: 55)
      .frame(maxWidth: .infinity)
      .background(.white)
      .cornerRadius(10)
      .shadow(radius: 10)
      .onTapGesture {
        handleNextButtonPressed()
      }
  }
  
  private var welcomeSection: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "figure.run.square.stack.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
        .foregroundColor(.white)
      
      Text("Celebrate Every Stribe")
        .textCase(.uppercase)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .overlay(
          Capsule(style: .continuous)
            .frame(height: 3)
            .offset(y: 5)
            .foregroundColor(.white)
          , alignment: .bottom
        )
      
      Text("Lace up those sneakers and hit the pavement! Our app is your running buddy, guiding you through exhilarating workouts, tracking your progress, and celebrating every milestone along the way.")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
      Spacer()
      Spacer()
    }
    .padding(30)
  }
  
  private var authorizeHealthKitSection: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "heart.text.square.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
        .foregroundColor(.white)
      
      Text("Let's Get Moving")
        .textCase(.uppercase)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .overlay(
          Capsule(style: .continuous)
            .frame(height: 3)
            .offset(y: 5)
            .foregroundColor(.white)
          , alignment: .bottom
        )
      
      Text("Once you give us the green light, we'll start bringing in all the fitness data you need, like your heart rate, activity levels, and more. We'll use this info to tailor your experience and provide you with personalized tips and encouragement.")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
      Spacer()
      Spacer()
    }
    .padding(30)
  }
  
  private var locationSeciton: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "location.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.white)
      
      Text("Enable location")
        .textCase(.uppercase)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .overlay(
          Capsule(style: .continuous)
            .frame(height: 3)
            .offset(y: 5)
            .foregroundColor(.white)
          , alignment: .bottom
        )
      
      Text("blah blah blah")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
      Spacer()
      Spacer()
    }
    .padding(30)
  }
  
  private var notificationSection: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "bubble.right")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.white)
      
      Text("Get notifition!")
        .textCase(.uppercase)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .overlay(
          Capsule(style: .continuous)
            .frame(height: 3)
            .offset(y: 5)
            .foregroundColor(.white)
          , alignment: .bottom
        )
      
      Text("blah blah blah")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
      Spacer()
      Spacer()
    }
    .padding(30)
  }
  
  private var doneSection: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "face.smiling.inverse")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.white)
      
      Text("All Done!")
        .textCase(.uppercase)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .overlay(
          Capsule(style: .continuous)
            .frame(height: 3)
            .offset(y: 5)
            .foregroundColor(.white)
          , alignment: .bottom
        )
      
      Text("Now you can start the jounry for this app.")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
      Spacer()
      Spacer()
    }
    .padding(30)
  }
}


// MARK: FUNCTIONS
extension Onboarding {
  func handleNextButtonPressed() {
    withAnimation(.spring()) {
      viewModel.handleButtonAction(with: viewModel.state)
    }
  }
}
