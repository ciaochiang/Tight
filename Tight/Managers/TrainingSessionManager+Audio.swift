//
//  TrainingSessionManager+Audio.swift
//  Tight
//
//  Created by Ciao Chiang on 2024/1/29.
//

import Foundation
import AVFoundation

// MARK: Audio
extension TrainingSessionManager {
    func prepareSoundEffect() {
        guard let soundURL = Bundle.main.url(forResource: "soundEffect", withExtension: "m4a") else { return }
             
        do {
           audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
           audioPlayer?.prepareToPlay()
        } catch {
           fatalError("Error initializing audio player: \(error.localizedDescription)")
        }
    }
}
