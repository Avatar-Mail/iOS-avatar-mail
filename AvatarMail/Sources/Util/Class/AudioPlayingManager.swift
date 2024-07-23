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
            
            guard let audioPlayer else { return .failure(.audioPlayerCreationFailure) }
            
            // 오디오 재생 준비
            audioPlayer.volume = 1
            audioPlayer.prepareToPlay()

            // 오디오 재생
            audioPlayer.play()
        } catch {
            return .failure(.audioPlayerCreationFailure)
        }
        
        return .success(())
    }
    
    public func stopPlaying() -> Result<Void, AudioPlayingError> {
        guard let audioPlayer else { return .failure(.audioPlayerNotFound) }
        
        audioPlayer.stop()
        
        return .success(())
    }
    
    public func cancelRecording() {
        initializeRecorder()
    }
    
    public func getRecordedTime(url: URL) -> Result<Double, AudioPlayingError> {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            let duration = audioPlayer.duration
            return .success(duration)
        } catch {
            return .failure(.audioPlayerCreationFailure)
        }
    }
    
    private func initializeRecorder() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}


extension AudioPlayingManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
    }
}


enum AudioPlayingError: Error {
    case playingSessionSetupFailure
    case audioPlayerCreationFailure
    case audioPlayerNotFound
}
