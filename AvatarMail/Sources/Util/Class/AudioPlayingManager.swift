//
//  AudioPlayingManager.swift
//  AvatarMail
//
//  Created by 최지석 on 7/20/24.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

final class AudioPlayingManager: NSObject {
    
    private var audioPlayer : AVAudioPlayer?
    private var playingTimer: CustomTimer?
    
    var playingTime = BehaviorSubject<Double>(value: 0)
    
    
    override init() { }
    
    
    public func startPlaying(url: URL) -> Result<Void, AudioPlayingError> {
        
        initializeRecorder()
        
        // AVAudioSession 설정
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            return .failure(.playingSessionSetupFailure)
        }
        
        do {
            // AVAudioPlayer 인스턴스 생성
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            
            // 타이머 인스턴스 생성
            playingTimer = CustomTimer()
            playingTimer?.delegate = self
            
            guard let audioPlayer else { return .failure(.audioPlayerCreationFailure) }
            guard let playingTimer else { return .failure(.timerCreationFailure)}
            
            // 오디오 재생 준비
            audioPlayer.volume = 1
            audioPlayer.prepareToPlay()
            // 타이머 시작
            playingTimer.startTimer()
            // 오디오 재생
            audioPlayer.play()
        } catch {
            return .failure(.audioPlayerCreationFailure)
        }
        
        return .success(())
    }
    
    
    public func stopPlaying() -> Result<Void, AudioPlayingError> {
        guard let audioPlayer else { return .failure(.audioPlayerNotFound) }
        guard let playingTimer else { return .failure(.timerNotFound)}
        
        audioPlayer.stop()
        playingTimer.stopTimer()
        
        return .success(())
    }
    
    public func cancelRecording() {
        initializeRecorder()
    }
    
    private func initializeRecorder() {
        audioPlayer?.stop()
        audioPlayer = nil
        playingTimer?.stopTimer()
        playingTimer = nil
        playingTime.onNext(0)
    }
}


extension AudioPlayingManager: CustomTimerDelegate {
    func timerUpdated(seconds: Double) {
        playingTime.onNext(seconds)
    }
}


extension AudioPlayingManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playingTimer?.stopTimer()
            playingTimer = nil
            audioPlayer = nil
        } else {
            initializeRecorder()
        }
    }
}


enum AudioPlayingError: Error {
    case playingSessionSetupFailure
    case audioPlayerCreationFailure
    case audioPlayerNotFound
    case timerCreationFailure
    case timerNotFound
}
