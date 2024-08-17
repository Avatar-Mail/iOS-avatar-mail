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

public protocol AudioPlayingManagerDelegate: AnyObject {
    func didFinishPlaying(with fileURL: String?)
}

final class AudioPlayingManager: NSObject {
        
    weak var delegate: AudioPlayingManagerDelegate?
    
    private var audioPlayer : AVAudioPlayer?
    
    private var storageManager: StorageManagerProtocol
    
    
    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
        
        super.init()
    }
    
    
    public func startPlaying(url: URL) -> Result<Void, AudioPlayingError> {
        
        initializePlayer()
        
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
    
    public func cancelPlaying() {
        initializePlayer()
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
    
    private func initializePlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}


extension AudioPlayingManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying(with: player.url?.absoluteString)
        audioPlayer = nil
    }
}


enum AudioPlayingError: Error {
    case playingSessionSetupFailure
    case audioPlayerCreationFailure
    case audioPlayerNotFound
}
