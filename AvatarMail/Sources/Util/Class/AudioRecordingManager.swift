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
    
    let recorderSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    private var audioRecorder : AVAudioRecorder?
    private var recording: AudioRecording?
    private var recordingTimer: CustomTimer?
    var recordingTime = BehaviorSubject<Double>(value: 0)
    
    
    override init() { }
    
    
    public func startRecording(with avatarName: String) -> Observable<AudioRecording> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self else {
                observer.onError(AudioRecordingError.audioRecordingManagerSetupFailure)
                return Disposables.create()
            }
            
            initializeRecorder()
            
            // AVAudioSession 설정
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setCategory(.playAndRecord, mode: .default)
                try session.setActive(true)
            } catch {
                observer.onError(AudioRecordingError.recordingSessionSetupFailure)
                return Disposables.create()
            }

            // AudioRecording 인스턴스 생성
            // 파일 ID
            let fileID = UUID().uuidString
            
            // 파일 이름
            let fileName = "음성 녹음 - \(avatarName).wav"

            // 파일 경로
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentPath.appendingPathComponent("\(avatarName)-\(fileID).wav")
            
            // 파일 생성 날짜
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            
            recording = AudioRecording(id: fileID,
                                       fileName: fileName,
                                       fileURL: fileURL,
                                       createdAtString: currentDate,
                                       recordingDuration: 0.0)
            
            guard let recording else {
                observer.onError(AudioRecordingError.recordingInstanceCreationFailure)
                return Disposables.create()
            }
            
            do {
                // AVAudioRecorder 인스턴스 생성
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: recorderSettings)
                // 타이머 인스턴스 생성
                recordingTimer = CustomTimer()
                recordingTimer?.delegate = self
                
                guard let recordingTimer else {
                    observer.onError(AudioRecordingError.timerNotFound)
                    return Disposables.create()
                }
                
                guard let audioRecorder else {
                    observer.onError(AudioRecordingError.audioRecorderNotFound)
                    return Disposables.create()
                }
                
                // 타이머 시작
                recordingTimer.startTimer()
                    
                // 음성 녹음 시작
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
            } catch {
                observer.onError(AudioRecordingError.audioRecorderCreationFailure)
                return Disposables.create()
            }
            
            observer.onNext(recording)
            return Disposables.create()
        }
    }
    
    public func stopRecording() -> Observable<AudioRecording> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self else {
                observer.onError(AudioRecordingError.audioRecordingManagerSetupFailure)
                return Disposables.create()
            }
            
            guard let audioRecorder else {
                observer.onError(AudioRecordingError.audioRecorderNotFound)
                return Disposables.create()
            }
            
            guard let recordingTimer else {
                observer.onError(AudioRecordingError.timerNotFound)
                return Disposables.create()
            }
            
            guard var recording else {
                observer.onError(AudioRecordingError.recordingInstanceNotFound)
                return Disposables.create()
            }
            
            audioRecorder.stop()
            recordingTimer.stopTimer()
            recording.recordingDuration = recordingTimer.getRecordedTime()
            
            observer.onNext(recording)
            return Disposables.create()
        }
    }
    
    
    private func initializeRecorder() {
        audioRecorder?.stop()
        audioRecorder = nil
        recordingTimer?.stopTimer()
        recordingTimer = nil
        recording = nil
        recordingTime.onNext(0)
    }
}


extension AudioRecordingManager: CustomTimerDelegate {
    func timerUpdated(seconds: Double) {
        recordingTime.onNext(seconds)
    }
}


enum AudioRecordingError: Error {
    case recordingSessionSetupFailure
    case recordingInstanceCreationFailure
    case recordingInstanceNotFound
    case audioRecorderCreationFailure
    case audioRecorderNotFound
    case timerInstanceCreationFailure
    case timerNotFound
    case audioRecordingManagerSetupFailure
}
