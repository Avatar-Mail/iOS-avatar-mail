////
////  AudioRecordingManager.swift
////  AvatarMail
////
////  Created by 최지석 on 7/20/24.
////
//
//import Foundation
//import AVFoundation
//
//final class AudioRecordingManager: NSObject {
//    
//    let recorderSettings = [
//        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//        AVSampleRateKey: 12000,
//        AVNumberOfChannelsKey: 1,
//        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//    ]
//    
//    public func startRecording() {
//        // AVAudioSession의 싱글턴 인스턴스를 가져옴
//        let session = AVAudioSession.sharedInstance()
//        do {
//            // 오디오 세션의 카테고리를 '녹음 및 재생'으로 설정
//            try session.setCategory(.playAndRecord, mode: .default)
//            // 오디오 세션 활성화
//            try session.setActive(true)
//        } catch {
//            // 세션 설정에 실패했을 경우 에러 메시지를 출력합니다.
//            print("Failed to set up recording session")
//        }
//
//        // 녹음 파일 저장을 위한 고유한 파일 이름을 생성합니다.
//        let fileName = UUID().uuidString + ".m4a"
//        // 문서 디렉터리의 경로를 가져옵니다.
//        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        // 파일의 전체 경로를 생성합니다.
//        let fileURL = documentPath.appendingPathComponent(fileName)
//        
//        // 녹음 설정을 정의합니다. AAC 포맷, 샘플 레이트 12000 Hz, 단일 채널, 높은 오디오 품질로 설정합니다.
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            // AVAudioRecorder 인스턴스를 생성하고 초기화합니다. 위에서 정의된 설정과 경로를 사용합니다.
//            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
//            // 미터링을 활성화하여 녹음 중 오디오 레벨을 측정할 수 있게 합니다.
//            audioRecorder.isMeteringEnabled = true
//            // 녹음 준비를 합니다.
//            audioRecorder.prepareToRecord()
//            // 녹음을 시작합니다.
//            audioRecorder.record()
//
//            // 녹음 시간을 계산하기 위한 타이머를 시작합니다. 1초마다 콜백이 실행됩니다.
//            countTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
//                self.countSec += 1
//                // 녹음 시간을 분과 초로 변환하여 문자열로 저장합니다.
//                self.timerString = self.covertSecToMinAndHour(seconds: self.countSec)
//            })
//            
//        } catch {
//            // 녹음 시작에 실패했을 경우 에러 메시지를 출력합니다.
//            print("Recording failed to start")
//        }
//    }
//}
