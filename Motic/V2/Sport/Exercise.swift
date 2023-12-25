//
//  Exercise.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/21.
//

import Foundation

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
        case .none: return "None"
        
        /// Upper Body
        case .benchPress: return "Bench Press"
        case .pushUp: return "Push Up"
        case .pullUp: return "Pull Up"
        case .bentOverRow: return "Bent-Over Row"
        case .dumbbellRow: return "Dumbbell Row"
        case .shoulderPress: return "Shoulder Press"
        case .lateralRaise: return "Lateral Raise"
        case .bicepCurl: return "Bicep Curl"
        case .tricepDip: return "Tricep Dip"
        case .latPulldown: return "Lat Pulldown"
        case .chestFly: return "Chest Fly"
        case .inclineBenchPress: return "Incline Bench Press"
        case .arnoldPress: return "Arnold Press"
        case .uprightRow: return "Upright Row"
        case .shrug: return "Shrug"
            
        /// Lower Body
        case .squat: return "Squat"
        case .deadlift: return "Deaflift"
        case .lunge: return "Lunge"
        case .legPress: return "Leg Press"
        case .calfRaise: return "Calf Raise"
        case .romanianDeadlift: return "Romanian Deadlift"
        case .gluteBridge: return "Glute Bridge"
        case .bulgarianSplitSquat: return "Bulgarian Split Squat"
        case .stepUp: return "Step Up"
        case .boxJump: return "Box Jump"
        case .legExtension: return "Leg Extension"
        case .hamstringCurl: return "Hamstring Curl"
            
        /// Core
        case .plank: return "Plank"
        case .russianTwist: return "Russian Twist"
        case .crunch: return "Crunch"
        case .legRaise: return "Leg Raise"
        case .bicycleCrunch: return "Bicycle Crunch"
        case .superman: return "Superman"
        case .hangingLegRaise: return "Hanging Leg Raise"
        case .woodchopper: return "Woodchopper"
            
        /// Compound and Full Body
        case .cleanAndJerk: return "Clean and Jerk"
        case .snatch: return "Snatch"
        case .kettleSwing: return "KettleSwing"
        case .medicineBallSlam: return "Medicine Ball Slams"
        case .battleRope: return "Battle Rope"
        case .burpee: return "Burpee"
        case .farmerWalk: return "Farmer's Walk"
        case .pushPress: return "Push Press"
        case .turkishGetUp: return "Turkish Get-Up"
        case .thruster: return "Thruster"
        case .wallBall: return "Walk Ball"
        case .rowingMachine: return "Rowing Machine"
        }
    }
}
