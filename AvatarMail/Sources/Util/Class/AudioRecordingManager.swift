//
//  AudioRecordingManager.swift
//  AvatarMail
//
//  Created by 최지석 on 7/20/24.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

final class AudioRecordingManager: NSObject {
    
    public static let shared = AudioRecordingManager()
    
    let settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    private var audioRecorder : AVAudioRecorder?
    private var audioSession: AVAudioSession
    private var recording: AudioRecording?
    
    
    private override init() {
        audioSession = AVAudioSession.sharedInstance()
        super.init()
    }
    
    
    public func startRecording(contents: String,
                               with avatarName: String) -> Result<AudioRecording, AudioRecordingError> {
        
        initializeRecorder()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            return .failure(.recordingSessionSetupFailure)
        }

        // AudioRecording 인스턴스 생성
        // 파일 ID
        let fileID = UUID().uuidString
        // 파일 이름
        let fileName: String = "\(avatarName)_\(fileID)"
        // 파일 경로
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentPath.appendingPathComponent("\(fileName).m4a")
        // 파일 생성 날짜
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        recording = AudioRecording(id: fileID,
                                   fileName: fileName,
                                   fileURL: fileURL,
                                   contents: contents,
                                   createdDate: currentDate,
                                   duration: 0.0)
        
        guard let recording else { return .failure(.recordingInstanceCreationFailure) }
        
        do {
            // AVAudioRecorder 인스턴스 생성
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)

            guard let audioRecorder else { return .failure(.audioRecorderCreationFailure) }
                
            // 음성 녹음 시작
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            return .failure(.audioRecorderCreationFailure)
        }
        
        return .success(recording)
    }
    
    
    public func stopRecording() -> Result<AudioRecording, AudioRecordingError> {
        guard let audioRecorder else { return .failure(.audioRecorderNotFound) }
        guard var recording else { return .failure(.recordingInstanceNotFound)}
        
        audioRecorder.stop()
        
        if let duration = getRecordedTime(url: recording.fileURL) {
            recording.duration = duration
            return .success(recording)
        } else {
            return .failure(.loadDurationFailure)
        }
    }
    
    private func getRecordedTime(url: URL) -> TimeInterval? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            let duration = audioPlayer.duration
            return duration
        } catch {
            print("Error initializing AVAudioPlayer: \(error)")
            return nil
        }
    }
    
    public func cancelRecording() {
        initializeRecorder()
    }
    
    private func initializeRecorder() {
        audioRecorder?.stop()
        audioRecorder = nil
        recording = nil
    }
}


enum AudioRecordingError: Error {
    case recordingSessionSetupFailure
    case recordingInstanceCreationFailure
    case recordingInstanceNotFound
    case audioRecorderCreationFailure
    case audioRecorderNotFound
    case loadDurationFailure
}
