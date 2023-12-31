//
//  LocalizationProvider.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/30.
//

import Foundation
import SwiftUI

enum LocalizationProvider {
    /// App Name
    case appName
    
    /// Common
    case tags
    case exercise
    case settings
    case favorites
    case noFavorites
    case noExercises
    case noPlans
    case newPlan
    case planName
    case plan
    case plans
    case pickExercise
    case notification
    case allowReceive
    
    /// Onboarding
    case onboardingWelcomeDescription
    case onboardingNotificationDescription
    
    /// Callout
    case startAddingExerciseToPlan
    case startCreatingNewPlan
    
    /// Placeholder
    case placeholderPlanNameTextfield
    
    /// Actions
    case add
    case addExercise
    case close
    case importFromPlans
    case create
    case createNewPlan
    case editPlan
    
    ///  Exericse Glossary
    case sets
    case repetitions
    case restIntervals
    
    /// Exercise Category
    case upperBody
    case lowerBody
    case core
    case compoundOrFullBody
    
    var nameKey: LocalizedStringKey {
        switch self {
        /// App Name
        case .appName: return "app_name"
            
        /// Common
        case .tags: return "common_key_tags"
        case .exercise: return "common_key_exercise"
        case .settings: return "common_key_settings"
        case .favorites: return "common_key_favorites"
        case .noFavorites: return "common_key_no_favorites"
        case .noExercises: return "common_key_no_exercises"
        case .noPlans: return "common_key_no_plans"
        case .newPlan: return "common_key_new_plan"
        case .planName: return "common_key_plan_name"
        case .plan: return "common_key_plan"
        case .plans: return "common_key_plans"
        case .pickExercise: return "common_key_pick_exercise"
        case .notification: return "common_key_notification"
        case .allowReceive: return "common_key_allow_receive"
            
        /// Onboarding
        case .onboardingWelcomeDescription: return "onboarding_key_welcome_description"
        case .onboardingNotificationDescription: return "onboarding_key_notification_description"
            
        ///  Callout
        case .startAddingExerciseToPlan: return "callout_key_start_adding_exercise_to_plan"
        case .startCreatingNewPlan: return "callout_key_start_creating_new_plan"
            
        ///  Placeholder
        case .placeholderPlanNameTextfield: return "placeholder_key_plan_name_textfield"
            
        /// Actions
        case .add: return "action_key_add"
        case .addExercise: return "action_key_add_exercise"
        case .close: return "action_key_close"
        case .importFromPlans: return "action_key_import_from_plans"
        case .create: return "action_key_create"
        case .createNewPlan: return "action_key_create_new_plan"
        case .editPlan: return "action_key_edit_plan"
            
        /// Exercise Glossary
        case .sets: return "exercise_glossary_sets"
        case .repetitions: return "exercise_glossary_repetitions"
        case .restIntervals: return "exercise_glossary_rest_intervals"
            
        /// Exercise Category
        case .upperBody: return "exercise_category_upper_body"
        case .lowerBody: return "exercise_category_lower_body"
        case .core: return "exercise_category_core"
        case .compoundOrFullBody: return "exercise_category_compound_or_fullbody"
        }
    }
}
