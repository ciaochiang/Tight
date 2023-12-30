//
//  Exercise.swift
//  Tight
//
//  Created by Ciao Chiang on 2023/12/28.
//

import Foundation
import SwiftUI

// MARK: Exercise
enum Exercise: Int, CaseIterable, Hashable, Codable {
    case none = 0
    
    /// Upper Body Exercise
    case benchPress = 1
    case pushUp = 2
    case pullUp = 3
    case bentOverRow = 4
    case dumbbellRow = 5
    case shoulderPress = 6
    case lateralRaise = 7
    case bicepCurl = 8
    case tricepDip = 9
    case latPulldown = 10
    case chestFly = 11
    case inclineBenchPress = 12
    case arnoldPress = 13
    case uprightRow = 14
    case shrug = 15
    
    /// Lower Body Exercise
    case squat = 101
    case deadlift = 102
    case lunge = 103
    case legPress = 104
    case calfRaise = 105
    case romanianDeadlift = 106
    case gluteBridge = 107
    case bulgarianSplitSquat = 108
    case stepUp = 109
    case boxJump = 110
    case legExtension = 111
    case hamstringCurl = 112
    
    /// Core Exercise
    case plank = 201
    case russianTwist = 202
    case crunch = 203
    case legRaise = 204
    case bicycleCrunch = 205
    case superman = 206
    case hangingLegRaise = 207
    case woodchopper = 208
    
    /// Compound and Full-Body Exercise
    case cleanAndJerk = 901
    case snatch = 902
    case kettleSwing = 903
    case medicineBallSlam = 904
    case battleRope = 905
    case burpee = 906
    case farmerWalk = 907
    case pushPress = 908
    case turkishGetUp = 909
    case thruster = 910
    case wallBall = 911
    case rowingMachine = 912
    
    static var upperBodyExercises: [Exercise] {
        return [
            .benchPress,
            .pushUp,
            .pullUp,
            .bentOverRow,
            .dumbbellRow,
            .shoulderPress,
            .lateralRaise,
            .bicepCurl,
            .tricepDip,
            .latPulldown,
            .chestFly,
            .inclineBenchPress,
            .arnoldPress,
            .uprightRow,
            .shrug
        ]
    }
    
    static var lowerBodyExercises: [Exercise] {
        return [
            .squat,
            .deadlift,
            .lunge,
            .legPress,
            .calfRaise,
            .romanianDeadlift,
            .gluteBridge,
            .bulgarianSplitSquat,
            .stepUp,
            .boxJump,
            .legExtension,
            .hamstringCurl
        ]
    }
    
    static var coreExercises: [Exercise] {
        return [
            .plank,
            .russianTwist,
            .crunch,
            .legRaise,
            .bicycleCrunch,
            .superman,
            .hangingLegRaise,
            .woodchopper
        ]
    }
    
    static var compoundExercises: [Exercise] {
        return [
            .cleanAndJerk,
            .snatch,
            .kettleSwing,
            .medicineBallSlam,
            .battleRope,
            .burpee,
            .farmerWalk,
            .pushPress,
            .turkishGetUp,
            .thruster,
            .wallBall,
            .rowingMachine
        ]
    }
    
    var name: String {
        switch self {
        case .none: return "exercise_key_none"
        
        /// Upper Body
        case .benchPress: return "exercise_key_bench_press"
        case .pushUp: return "exercise_key_push_up"
        case .pullUp: return "exercise_key_pull_up"
        case .bentOverRow: return "exercise_key_bent_over_row"
        case .dumbbellRow: return "exercise_key_dumbbell_row"
        case .shoulderPress: return "exercise_key_shoulder_press"
        case .lateralRaise: return "exercise_key_lateral_raise"
        case .bicepCurl: return "exercise_key_bicep_curl"
        case .tricepDip: return "exercise_key_tricep_dip"
        case .latPulldown: return "exercise_key_lat_pulldown"
        case .chestFly: return "exercise_key_chest_fly"
        case .inclineBenchPress: return "exercise_key_incline_bench_press"
        case .arnoldPress: return "exercise_key_arnold_press"
        case .uprightRow: return "exercise_key_upright_row"
        case .shrug: return "exercise_key_shrug"
            
        /// Lower Body
        case .squat: return "exercise_key_squat"
        case .deadlift: return "exercise_key_deaflift"
        case .lunge: return "exercise_key_lunge"
        case .legPress: return "exercise_key_leg_press"
        case .calfRaise: return "exercise_key_calf_raise"
        case .romanianDeadlift: return "exercise_key_romanian_deadlift"
        case .gluteBridge: return "exercise_key_glute_bridge"
        case .bulgarianSplitSquat: return "exercise_key_bulgarian_split_squat"
        case .stepUp: return "exercise_key_step_up"
        case .boxJump: return "exercise_key_box_jump"
        case .legExtension: return "exercise_key_leg_extension"
        case .hamstringCurl: return "exercise_key_hamstring_curl"
            
        /// Core
        case .plank: return "exercise_key_plank"
        case .russianTwist: return "exercise_key_russian_twist"
        case .crunch: return "exercise_key_crunch"
        case .legRaise: return "exercise_key_leg_raise"
        case .bicycleCrunch: return "exercise_key_bicycle_crunch"
        case .superman: return "exercise_key_superman"
        case .hangingLegRaise: return "exercise_key_hanging_leg_raise"
        case .woodchopper: return "exercise_key_woodchopper"
            
        /// Compound and Full Body
        case .cleanAndJerk: return "exercise_key_clean_and_jerk"
        case .snatch: return "exercise_key_snatch"
        case .kettleSwing: return "exercise_key_kettle_swing"
        case .medicineBallSlam: return "exercise_key_medicine_ball_slams"
        case .battleRope: return "exercise_key_battle_rope"
        case .burpee: return "exercise_key_burpee"
        case .farmerWalk: return "exercise_key_farmer_walk"
        case .pushPress: return "exercise_key_push_press"
        case .turkishGetUp: return "exercise_key_turkish_get_Up"
        case .thruster: return "exercise_key_thruster"
        case .wallBall: return "exercise_key_walk_ball"
        case .rowingMachine: return "exercise_key_rowing_machine"
        }
    }
}


// MARK: ExericiseTag
enum ExerciseTag: Int, CaseIterable, Hashable, Codable {
    case others = 0
    
    /// Ground Hardware
    case bench = 1
    case rack = 2
    case machine = 3
    case pullupBar = 4
    case treadmill = 5
    case rower = 6
    
    ///  Hand Handware
    case dumbbell = 100
    case barbell = 101
    case resistanceBand = 102
    case kettlebell = 103
    case medicineBall = 104
    case tricepRope = 105
    case battleRope = 106
    case trx = 107
    
    var namekey: LocalizedStringKey {
        switch self {
        case .others: return "exercise_tag_key_others"
            
        case .bench: return "exercise_tag_key_bench"
        case .rack: return "exercise_tag_key_rack"
        case .machine: return "exercise_tag_key_machine"
        case .pullupBar: return "exercise_tag_key_pull_up_bar"
        case .treadmill: return "exercise_tag_key_treadmill"
        case .rower: return "exercise_tag_key_rower"
            
        case .dumbbell: return "exercise_tag_key_dumbbell"
        case .barbell: return "exercise_tag_key_barbell"
        case .resistanceBand: return "exercise_tag_key_resistance_band"
        case .kettlebell: return "exercise_tag_key_kettlebell"
        case .medicineBall: return "exercise_tag_key_medicine_ball"
            
        case .tricepRope: return "exercise_tag_key_tricep_rope"
        case .battleRope: return "exercise_tag_key_battle_rope"
        case .trx: return "exercise_tag_key_trx"
        }
    }
}
