import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import AVFoundation

class SettingHomeController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let recordingManager = AudioRecordingManager()
    let playingManager = AudioPlayingManager()
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    private let recordingStartButton = UIButton().then {
        $0.setTitle("녹음 시작", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
    }
    
    private let recordingStopButton = UIButton().then {
        $0.setTitle("녹음 종료", for: .normal)
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 8
    }
    
    private let playingStartButton = UIButton().then {
        $0.setTitle("재생 시작", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
    }
    
    private let playingStopButton = UIButton().then {
        $0.setTitle("재생 종료", for: .normal)
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 8
    }
    
    // 파일
    private let fileNameLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "FileName: ",
                                                  color: .black,
                                                  fontSize: 24,
                                                  fontWeight: .bold)
        $0.numberOfLines = 0
    }
    
    private let fileUrlLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "FileURL: ",
                                                  color: .darkGray,
                                                  fontSize: 20,
                                                  fontWeight: .medium)
        $0.numberOfLines = 0
    }
    
    private let createdDateLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "Date: ",
                                                  color: .gray,
                                                  fontSize: 20,
                                                  fontWeight: .medium)
        $0.numberOfLines = 1
    }
    
    // 음성 녹음
    private let recordingTitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "음성 기록 시간",
                                                  color: .black,
                                                  fontSize: 20,
                                                  fontWeight: .semibold)
    }
    
    private let recordingMinutesLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    private let recordingSecondsLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    private let recordingMillisecondsLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    // 음성 재생
    private let playingTitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "음성 재생 시간",
                                                  color: .black,
                                                  fontSize: 20,
                                                  fontWeight: .semibold)
    }
    
    private let playingMinutesLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    private let playingSecondsLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    private let playingMillisecondsLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.attributedText = .makeAttributedString(text: "00",
                                                  color: .black,
                                                  fontSize: 18,
                                                  fontWeight: .medium)
    }
    
    
    // 음성 녹음 파일
    private var currentRecording: AudioRecording?
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindUI()
    }
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            
            fileNameLabel,
            fileUrlLabel,
            createdDateLabel,
            
            recordingTitleLabel,
            recordingMinutesLabel,
            recordingSecondsLabel,
            recordingMillisecondsLabel,
            
            playingTitleLabel,
            playingMinutesLabel,
            playingSecondsLabel,
            playingMillisecondsLabel,
            
            recordingStartButton,
            recordingStopButton,
        
            playingStartButton,
            playingStopButton
        )
        
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        // 파일 설정
        fileNameLabel.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        fileUrlLabel.snp.makeConstraints {
            $0.top.equalTo(fileNameLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        // 음성 기록 시간
        recordingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(100)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        recordingMillisecondsLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(30)
        }
        
        recordingSecondsLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(20)
            $0.trailing.equalTo(recordingMillisecondsLabel.snp.leading)
            $0.width.equalTo(30)
        }

        recordingMinutesLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(20)
            $0.trailing.equalTo(recordingSecondsLabel.snp.leading)
            $0.width.equalTo(30)
        }
        
        // 음성 재생 시간
        playingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(100)
            $0.leading.equalToSuperview().inset(20)
        }
        
        playingMinutesLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(30)
        }
        
        playingSecondsLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(playingMinutesLabel.snp.trailing)
            $0.width.equalTo(30)
        }
        
        playingMillisecondsLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(playingSecondsLabel.snp.trailing)
            $0.width.equalTo(30)
        }

        // 음성 녹음 버튼
        recordingStartButton.snp.makeConstraints {
            $0.top.equalTo(recordingMinutesLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview().offset(-70)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
        }
        
        recordingStopButton.snp.makeConstraints {
            $0.top.equalTo(recordingMinutesLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview().offset(70)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
        }
        
        // 음성 재생 버튼
        playingStartButton.snp.makeConstraints {
            $0.top.equalTo(recordingStartButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview().offset(-70)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
        }
        
        playingStopButton.snp.makeConstraints {
            $0.top.equalTo(recordingStartButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview().offset(70)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
        }
    }
    
    private func bindUI() {
        recordingStartButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                let result = self.recordingManager.startRecording(contents: "Hello",
                                                                  with: "AvatarName")
                
                switch result {
                case .success(let recording):
                    print("Recording Start")
                    currentRecording = recording
                    playingManager.playingTime.onNext(0)
                    
                    fileNameLabel.attributedText = .makeAttributedString(text: "FileName: \(recording.fileName)",
                                                                         color: .black,
                                                                         fontSize: 24,
                                                                         fontWeight: .bold)
                    fileUrlLabel.attributedText = .makeAttributedString(text: "FileURL: \(recording.fileURL.absoluteString)",
                                                                        color: .darkGray,
                                                                        fontSize: 20,
                                                                        fontWeight: .medium)
                    createdDateLabel.attributedText = .makeAttributedString(text: "Date: \(recording.createdDate)",
                                                                            color: .gray,
                                                                            fontSize: 20,
                                                                            fontWeight: .medium)
                case .failure(let error):
                    switch error {
                    case .audioRecorderCreationFailure:
                        print("audioRecorderCreationFailure")
                    case .audioRecorderNotFound:
                        print("audioRecorderNotFound")
                    case .recordingInstanceCreationFailure:
                        print("recordingInstanceCreationFailure")
                    case .recordingInstanceNotFound:
                        print("recordingInstanceCreationFailure")
                    case .recordingSessionSetupFailure:
                        print("recordingSessionSetupFailure")
                    case .timerCreationFailure:
                        print("timerInstanceCreationFailure")
                    case .timerNotFound:
                        print("timerNotFound")
                    }
                }
            }.disposed(by: disposeBag)
        
        recordingStopButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                let result = self.recordingManager.stopRecording()
                
                switch result {
                case .success(let recording):
                    print("Recording End")
                    currentRecording = recording
                case .failure(let error):
                    switch error {
                    case .audioRecorderCreationFailure:
                        print("audioRecorderCreationFailure")
                    case .audioRecorderNotFound:
                        print("audioRecorderNotFound")
                    case .recordingInstanceCreationFailure:
                        print("recordingInstanceCreationFailure")
                    case .recordingInstanceNotFound:
                        print("recordingInstanceCreationFailure")
                    case .recordingSessionSetupFailure:
                        print("recordingSessionSetupFailure")
                    case .timerCreationFailure:
                        print("timerInstanceCreationFailure")
                    case .timerNotFound:
                        print("timerNotFound")
                    }
                }
            }.disposed(by: disposeBag)
        
        playingStartButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                
                if let recording = self.currentRecording {
                    let result = self.playingManager.startPlaying(url: recording.fileURL)
                    
                    switch result {
                    case .success:
                        print("Playing Start")
                    case .failure(let error):
                        switch error {
                        case .audioPlayerCreationFailure:
                            print("audioPlayerCreationFailure")
                        case .audioPlayerNotFound:
                            print("audioPlayerNotFound")
                        case .playingSessionSetupFailure:
                            print("playingSessionSetupFailure")
                        case .timerCreationFailure:
                            print("timerCreationFailure")
                        case .timerNotFound:
                            print("timerNotFound")
                        }
                    }
                } else {
                    print("Recording Not Found")
                }
            }.disposed(by: disposeBag)
        
        playingStopButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                
                if let recording = self.currentRecording {
                    let result = self.playingManager.stopPlaying()
                    
                    switch result {
                    case .success:
                        print("Playing End")
                    case .failure(let error):
                        switch error {
                        case .audioPlayerCreationFailure:
                            print("audioPlayerCreationFailure")
                        case .audioPlayerNotFound:
                            print("audioPlayerNotFound")
                        case .playingSessionSetupFailure:
                            print("playingSessionSetupFailure")
                        case .timerCreationFailure:
                            print("timerCreationFailure")
                        case .timerNotFound:
                            print("timerNotFound")
                        }
                    }
                } else {
                    print("Recording Not Found")
                }
            }.disposed(by: disposeBag)
  
        recordingManager.recordingTime
            .subscribe(onNext: { [weak self] seconds in
                guard let self else { return }
                
                let totalMilliseconds = Int(seconds * 1000)
                let minutes = (totalMilliseconds / 1000) / 60
                let seconds = (totalMilliseconds / 1000) % 60
                let milliseconds = (totalMilliseconds % 1000) / 10
                
                recordingMinutesLabel.attributedText = .makeAttributedString(text: String(format: "%02d", minutes),
                                                                             color: .black,
                                                                             fontSize: 18,
                                                                             fontWeight: .medium)
                
                recordingSecondsLabel.attributedText = .makeAttributedString(text: String(format: "%02d", seconds),
                                                                             color: .black,
                                                                             fontSize: 18,
                                                                             fontWeight: .medium)
                
                recordingMillisecondsLabel.attributedText = .makeAttributedString(text: String(format: "%02d", milliseconds),
                                                                             color: .black,
                                                                             fontSize: 18,
                                                                             fontWeight: .medium)
            }).disposed(by: disposeBag)
        
        playingManager.playingTime
            .subscribe(onNext: { [weak self] seconds in
                guard let self else { return }
                
                let totalMilliseconds = Int(seconds * 1000)
                let minutes = (totalMilliseconds / 1000) / 60
                let seconds = (totalMilliseconds / 1000) % 60
                let milliseconds = (totalMilliseconds % 1000) / 10
                
                playingMinutesLabel.attributedText = .makeAttributedString(text: String(format: "%02d", minutes),
                                                                           color: .black,
                                                                           fontSize: 18,
                                                                           fontWeight: .medium)
                
                playingSecondsLabel.attributedText = .makeAttributedString(text: String(format: "%02d", seconds),
                                                                           color: .black,
                                                                           fontSize: 18,
                                                                           fontWeight: .medium)
                
                playingMillisecondsLabel.attributedText = .makeAttributedString(text: String(format: "%02d", milliseconds),
                                                                                color: .black,
                                                                                fontSize: 18,
                                                                                fontWeight: .medium)
            }).disposed(by: disposeBag)
    }
}


//import Foundation
//import UIKit
//import Then
//import SnapKit
//import RxSwift
//import RxCocoa
//import ReactorKit
//import AVFoundation
//
//class SettingHomeController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
//    
//    var disposeBag = DisposeBag()
//    
//    private let pageTitleLabel = UILabel().then {
//        $0.text = "설정"
//        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//    }
//    
//    private var recordButton = UIButton().then {
//        $0.setTitle("녹음 시작", for: .normal)
//        $0.setTitleColor(.blue, for: .normal)
//    }
//    
//    private var playButton = UIButton().then {
//        $0.setTitle("실행", for: .normal)
//        $0.setTitleColor(.blue, for: .normal)
//    }
//    
//    private var textField = UITextField().then {
//        $0.placeholder = "파일 이름 입력"
//        $0.borderStyle = .roundedRect
//    }
//    
//    private var minuteLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//    }
//    
//    private var secondLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//    }
//    
//    private var millisecondLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//    }
//    
//    var audioRecorder: AVAudioRecorder!
//    var audioPlayer: AVAudioPlayer!
//    var isRecording = false
//    var isPlaying = false
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        makeUI()
//        setupRecorder()
//        
//        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
//        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
//    }
//    
//    private var timer: CustomTimer?
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        timer = CustomTimer()
//        timer?.delegate = self
//        timer?.startTimer()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
//            self?.timer?.stopTimer()
//        }
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        timer?.stopTimer()
//        timer = nil
//    }
//    
//    private func makeUI() {
//        view.backgroundColor = .white
//        
//        view.addSubview(pageTitleLabel)
//        view.addSubview(recordButton)
//        view.addSubview(textField)
//        view.addSubview(playButton)
//        view.addSubview(minuteLabel)
//        view.addSubview(secondLabel)
//        view.addSubview(millisecondLabel)
//        
//        // title label
//        pageTitleLabel.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
//            $0.left.equalToSuperview().inset(20)
//        }
//        
//        // 녹음 버튼
//        recordButton.snp.makeConstraints {
//            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(20)
//            $0.centerX.equalToSuperview()
//            $0.width.equalTo(100)
//            $0.height.equalTo(50)
//        }
//        
//        // 텍스트 필드
//        textField.snp.makeConstraints {
//            $0.top.equalTo(recordButton.snp.bottom).offset(20)
//            $0.centerX.equalToSuperview()
//            $0.width.equalTo(200)
//            $0.height.equalTo(40)
//        }
//        
//        // 실행 버튼
//        playButton.snp.makeConstraints {
//            $0.top.equalTo(textField.snp.bottom).offset(20)
//            $0.centerX.equalToSuperview()
//            $0.width.equalTo(100)
//            $0.height.equalTo(50)
//        }
//        
//        minuteLabel.snp.makeConstraints {
//            $0.top.equalTo(playButton.snp.bottom).offset(20)
//            $0.left.equalTo(view.snp.centerX).offset(-60)
//        }
//        
//        secondLabel.snp.makeConstraints {
//            $0.top.equalTo(playButton.snp.bottom).offset(20)
//            $0.centerX.equalToSuperview()
//        }
//        
//        millisecondLabel.snp.makeConstraints {
//            $0.top.equalTo(playButton.snp.bottom).offset(20)
//            $0.left.equalTo(view.snp.centerX).offset(60)
//        }
//    }
//    
//    private func setupRecorder() {
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default)
//            try audioSession.setActive(true)
//            
//            let url = getDocumentsDirectory().appendingPathComponent("a.m4a")
//            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            audioRecorder.delegate = self
//        } catch {
//            print("Failed to setup recorder: \(error)")
//        }
//    }
//    
//    @objc func recordButtonTapped() {
//        if isRecording {
//            audioRecorder.stop()
//            recordButton.setTitle("녹음 시작", for: .normal)
//        } else {
//            audioRecorder.record()
//            recordButton.setTitle("녹음 종료", for: .normal)
//        }
//        isRecording.toggle()
//    }
//    
//    @objc func playButtonTapped() {
//        if isPlaying {
//            audioPlayer.stop()
//            playButton.setTitle("실행", for: .normal)
//        } else {
//            guard let filename = textField.text, !filename.isEmpty else { return }
//            let url = getDocumentsDirectory().appendingPathComponent("\(filename).m4a")
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: url)
//                audioPlayer.delegate = self
//                audioPlayer.play()
//                playButton.setTitle("중지", for: .normal)
//            } catch {
//                print("Failed to play audio: \(error)")
//            }
//        }
//        isPlaying.toggle()
//    }
//    
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
//    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playButton.setTitle("실행", for: .normal)
//        isPlaying = false
//    }
//}
//
//
//extension SettingHomeController: CustomTimerDelegate {
//    
//    func convertSecondsToTimeString(seconds: Double) -> (String, String, String) {
//        let totalMilliseconds = Int(seconds * 1000)
//        let minutes = (totalMilliseconds / 1000) / 60
//        let secs = (totalMilliseconds / 1000) % 60
//        let millisecs = (totalMilliseconds % 1000) / 10
//        
//        return (String(format: "%02d", minutes), String(format: "%02d", secs), String(format: "%02d", millisecs))
//    }
//    
//    func timerUpdated(seconds: Double) {
//        let (minutes, seconds, millisecs) = convertSecondsToTimeString(seconds: seconds)
//        minuteLabel.text = minutes
//        secondLabel.text = seconds
//        millisecondLabel.text = millisecs
//    }
//}
