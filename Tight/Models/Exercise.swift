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
    case kettlebellSwing = 903
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
            .kettlebellSwing,
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
        return String(localized: nameKey)
    }
    
    var nameKey: String.LocalizationValue {
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
        case .kettlebellSwing: return "exercise_key_kettlebell_swing"
        case .medicineBallSlam: return "exercise_key_medicine_ball_slams"
        case .battleRope: return "exercise_key_battle_rope"
        case .burpee: return "exercise_key_burpee"
        case .farmerWalk: return "exercise_key_farmer_walk"
        case .pushPress: return "exercise_key_push_press"
        case .turkishGetUp: return "exercise_key_turkish_get_Up"
        case .thruster: return "exercise_key_thruster"
        case .wallBall: return "exercise_key_wall_ball"
        case .rowingMachine: return "exercise_key_rowing_machine"
        }
    }
    
    var supportedTags: [ExerciseTag] {
        switch self {
        case .none: return []
        case .benchPress: return [.dumbbell, .barbell, .kettlebell, .medicineBall, .others]
        case .pushUp: return [.pushupBar, .pushupGrips, .resistanceBand, .stabilityBall, .others]
        case .pullUp: return [.pullupBar, .resistanceBand, .trx, .others]
        case .bentOverRow: return [.barbell, .dumbbell, .kettlebell, .resistanceBand, .weightPlates, .others]
        case .dumbbellRow: return [.dumbbell, .kettlebell, .bench, .rack, .others]
        case .shoulderPress: return [.barbell, .dumbbell, .weightPlates, .kettlebell, .resistanceBand, .others]
        case .lateralRaise: return [.dumbbell, .weightPlates, .resistanceBand, .others]
        case .bicepCurl: return [.dumbbell, .barbell, .kettlebell, .resistanceBand]
        case .tricepDip: return [.parallelBar, .resistanceBand]
        case .latPulldown: return [.pulldownBar, .weightPlates, .resistanceBand]
        case .chestFly: return [.dumbbell, .machineChestFly, .machineCableCrossOver]
        case .inclineBenchPress: return [.barbell, .dumbbell, .weightPlates]
        case .arnoldPress: return [.dumbbell, .kettlebell, .resistanceBand]
        case .uprightRow: return [.barbell, .dumbbell, .kettlebell, .weightPlates, .resistanceBand]
        case .shrug: return [.barbell, .dumbbell, .kettlebell, .weightPlates]
        case .squat: return [.barbell, .dumbbell, .weightPlates, .resistanceBand]
        case .deadlift: return [.barbell, .dumbbell, .kettlebell, .weightPlates, .resistanceBand]
        case .lunge: return [.dumbbell, .kettlebell, .resistanceBand]
        case .legPress: return [.machineLegPress, .weightPlates, .resistanceBand]
        case .calfRaise: return [.dumbbell, .barbell, .weightPlates, .machineCalfRaise, .machineSmith]
        case .romanianDeadlift: return [.barbell, .dumbbell, .weightPlates, .resistanceBand, .machineSmith]
        case .gluteBridge: return [.barbell, .dumbbell, .resistanceBand, .machineGluteBridge]
        case .bulgarianSplitSquat: return [.dumbbell, .barbell, .kettlebell, .resistanceBand]
        case .stepUp: return [.dumbbell, .barbell, .kettlebell, .resistanceBand]
        case .boxJump: return []
        case .legExtension: return [.machineLegExtension]
        case .hamstringCurl: return [.machineHamstringCurl]
        case .plank: return []
        case .russianTwist: return [.medicineBall, .stabilityBall, .resistanceBand]
        case .crunch: return [.stabilityBall, .abRoller]
        case .legRaise: return [.pullupBar, .stabilityBall, .resistanceBand]
        case .bicycleCrunch: return [.medicineBall, .resistanceBand, .stabilityBall, .ankleWeights]
        case .superman: return [.stabilityBall, .resistanceBand, .ankleWeights]
        case .hangingLegRaise: return [.pullupBar, .resistanceBand, .ankleWeights]
        case .woodchopper: return [.machineCable, .resistanceBand]
        case .cleanAndJerk: return [.barbell, .weightPlates]
        case .snatch: return [.barbell, .weightPlates]
        case .kettlebellSwing: return [.kettlebell]
        case .medicineBallSlam: return [.medicineBall]
        case .battleRope: return [.battleRope]
        case .burpee: return []
        case .farmerWalk: return [.dumbbell, .kettlebell]
        case .pushPress: return [.barbell, .weightPlates]
        case .turkishGetUp: return [.dumbbell, .kettlebell]
        case .thruster: return [.barbell, .dumbbell, .weightPlates]
        case .wallBall: return [.medicineBall]
        case .rowingMachine: return [.machineRowing]
        }
    }
    
    var platformTags: [ExerciseTag] {
        return [.bench, .rack, .machine, .yogaBlocks, .yogaMat, .pyloBox]
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
    case pushupBar = 7
    case pushupGrips = 8
    case yogaBlocks = 9
    case yogaMat = 10
    case parallelBar = 11
    case pulldownBar = 12
    case pyloBox = 13
    
    ///  Hand Handware
    case dumbbell = 100
    case barbell = 101
    case resistanceBand = 102
    case kettlebell = 103
    case medicineBall = 104
    case tricepRope = 105
    case battleRope = 106
    case trx = 107
    case weightPlates = 108
    case stabilityBall = 109
    case abRoller = 110
    case ankleWeights = 111
    
    /// Machine
    case machineCableCrossOver = 500
    case machineChestFly = 501
    case machineLegPress = 502
    case machineCalfRaise = 503
    case machineSmith = 504
    case machineGluteBridge = 505
    case machineLegExtension = 506
    case machineHamstringCurl = 507
    case machineCable = 508
    case machineRowing = 509
    
    var namekey: LocalizedStringKey {
        switch self {
        case .others: return "exercise_tag_key_others"
            
        /// Ground Hardware
        case .bench: return "exercise_tag_key_bench"
        case .rack: return "exercise_tag_key_rack"
        case .machine: return "exercise_tag_key_machine"
        case .pullupBar: return "exercise_tag_key_pull_up_bar"
        case .treadmill: return "exercise_tag_key_treadmill"
        case .rower: return "exercise_tag_key_rower"
        case .pushupBar: return "exercise_tag_push_up_bar"
        case .pushupGrips: return "exercise_tag_push_up_grips"
        case .yogaBlocks: return "exercise_tag_yoga_blocks"
        case .yogaMat: return "exercise_tag_yoga_mat"
        case .parallelBar: return "exercise_tag_parallel_bar"
        case .pulldownBar: return "exercise_tag_pull_down_bar"
        case .pyloBox: return "exercise_tag_pylo_box"
            
        ///  Hand Handware
        case .dumbbell: return "exercise_tag_key_dumbbell"
        case .barbell: return "exercise_tag_key_barbell"
        case .resistanceBand: return "exercise_tag_key_resistance_band"
        case .kettlebell: return "exercise_tag_key_kettlebell"
        case .medicineBall: return "exercise_tag_key_medicine_ball"
        case .tricepRope: return "exercise_tag_key_tricep_rope"
        case .battleRope: return "exercise_tag_key_battle_rope"
        case .trx: return "exercise_tag_key_trx"
        case .weightPlates: return "exercise_tag_weight_plates"
        case .stabilityBall: return "exercise_tag_stability_ball"
        case .abRoller: return "exercise_tag_ab_roller"
        case .ankleWeights: return "exercise_tag_ankle_weights"
            
        /// Machine
        case .machineCableCrossOver: return "exercise_tag_machine_cable_cross_over"
        case .machineChestFly: return "exercise_tag_machine_chest_fly"
        case .machineLegPress: return "exercise_tag_machine_leg_press"
        case .machineCalfRaise: return "exercise_tag_machine_calf_raise"
        case .machineSmith: return "exercise_tag_machine_smith"
        case .machineGluteBridge: return "exercise_tag_machine_glute_bridge"
        case .machineLegExtension: return "exercise_tag_machine_leg_extension"
        case .machineHamstringCurl: return "exercise_tag_machine_hamstring_curl"
        case .machineCable: return "exercise_tag_machine_cable"
        case .machineRowing: return "exercise_tag_machine_rowing"
        }
    }
}
