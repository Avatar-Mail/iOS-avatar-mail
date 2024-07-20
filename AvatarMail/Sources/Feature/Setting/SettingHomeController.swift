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
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    private let startButton = UIButton().then {
        $0.setTitle("녹음 시작", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
    }
    
    private let stopButton = UIButton().then {
        $0.setTitle("녹음 종료", for: .normal)
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 8
    }
    
    private let recordingTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let fileNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
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
        
        view.addSubview(pageTitleLabel)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(recordingTimeLabel)
        view.addSubview(fileNameLabel)
        
        // title label
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        stopButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startButton.snp.bottom).offset(20)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        recordingTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stopButton.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordingTimeLabel.snp.bottom).offset(20)
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
    }
    
    private func bindUI() {
        startButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                let result = self.recordingManager.startRecording(with: "AvatarName")
                
                switch result {
                case .success(let recording):
                    print(recording)
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
                    case .timerInstanceCreationFailure:
                        print("timerInstanceCreationFailure")
                    case .timerNotFound:
                        print("timerNotFound")
                    }
                }
            }.disposed(by: disposeBag)
        
        stopButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                let result = self.recordingManager.stopRecording()
                
                switch result {
                case .success(let recording):
                    print(recording)
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
                    case .timerInstanceCreationFailure:
                        print("timerInstanceCreationFailure")
                    case .timerNotFound:
                        print("timerNotFound")
                    }
                }
            }.disposed(by: disposeBag)
        
        recordingManager.recordingTime
            .subscribe(onNext: { [weak self] seconds in
                guard let self else { return }
                recordingTimeLabel.text = String(seconds)
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
