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
    
    let recordingManager: AudioRecordingManager
    let playingManager: AudioPlayingManager
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    // scroll-view
    private let pageScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    // scroll content-view
    private let pageContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // content stackview
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.backgroundColor = .clear
        $0.spacing = 20
        $0.isLayoutMarginsRelativeArrangement = true
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
                                                  fontSize: 20,
                                                  fontWeight: .bold)
        $0.numberOfLines = 0
    }
    
    private let fileUrlLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "FileURL: ",
                                                  color: .darkGray,
                                                  fontSize: 16,
                                                  fontWeight: .medium)
        $0.numberOfLines = 0
    }
    
    private let createdDateLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "Date: ",
                                                  color: .gray,
                                                  fontSize: 16,
                                                  fontWeight: .medium)
        $0.numberOfLines = 1
    }
    
    // 음성 녹음
    private let recordingTitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "음성 기록 시간",
                                                  color: .black,
                                                  fontSize: 16,
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
                                                  fontSize: 16,
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
    
    private let textViewContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let inputTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.isScrollEnabled = true
    }
    
    private let sendMailButton = UIButton().then {
        $0.setTitle("편지 보내기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
    }
    
    private let playServerSentFileButton = UIButton().then {
        $0.setTitle("음성 파일 실행", for: .normal)
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 8
    }
    
    // 타이머
    private let recordingTimer = CustomTimer(identifier: "RecordingTimer", interval: 0.01)
    private let playingTimer = CustomTimer(identifier: "PlayingTimer", interval: 0.01)
    
    // 음성 녹음/재생 시간
    private let recordingTime = BehaviorSubject<Double>(value: 0.0)
    private let playingTime = BehaviorSubject<Double>(value: 0.0)
    
    // 음성 녹음 파일
    private var currentRecording: AudioRecording?
    // 편지 내용
    private var mailContents: String?
    // 서버가 보낸 파일 URL
    private var serverSentFileURL: URL?
    
    
    init() {
        self.recordingManager = AppContainer.shared.getAudioRecordingManager()
        self.playingManager = AppContainer.shared.getAudioPlayingManager()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindUI()
        
        recordingTimer.delegate = self
        playingTimer.delegate = self
    }
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            
            pageScrollView.addSubViews(
                pageContentView.addSubViews(
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
                    playingStopButton,
                    
                    textViewContainerView.addSubViews(
                        inputTextView
                    ),
                    
                    sendMailButton,
                    playServerSentFileButton
                )
            )
        )
        
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        pageScrollView.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
        
        pageContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // 파일 설정
        fileNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        fileUrlLabel.snp.makeConstraints {
            $0.top.equalTo(fileNameLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        // 음성 기록 시간
        recordingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(50)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        recordingMillisecondsLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(30)
        }
        
        recordingSecondsLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(recordingMillisecondsLabel.snp.leading)
            $0.width.equalTo(30)
        }

        recordingMinutesLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(recordingSecondsLabel.snp.leading)
            $0.width.equalTo(30)
        }
        
        // 음성 재생 시간
        playingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(fileUrlLabel.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(20)
        }
        
        playingMinutesLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(30)
        }
        
        playingSecondsLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(playingMinutesLabel.snp.trailing)
            $0.width.equalTo(30)
        }
        
        playingMillisecondsLabel.snp.makeConstraints {
            $0.top.equalTo(playingTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(playingSecondsLabel.snp.trailing)
            $0.width.equalTo(30)
        }

        // 음성 녹음 버튼
        recordingStartButton.snp.makeConstraints {
            $0.top.equalTo(recordingMinutesLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        recordingStopButton.snp.makeConstraints {
            $0.top.equalTo(recordingStartButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        // 음성 재생 버튼
        playingStartButton.snp.makeConstraints {
            $0.top.equalTo(recordingMinutesLabel.snp.bottom).offset(30)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        playingStopButton.snp.makeConstraints {
            $0.top.equalTo(playingStartButton.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        textViewContainerView.snp.makeConstraints {
            $0.top.equalTo(playingStopButton.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }
        
        inputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        sendMailButton.snp.makeConstraints {
            $0.top.equalTo(textViewContainerView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(60)
            $0.width.equalTo(150)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        playServerSentFileButton.snp.makeConstraints {
            $0.top.equalTo(textViewContainerView.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
            $0.width.equalTo(150)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindUI() {
        recordingStartButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                let result = self.recordingManager.startRecording(contents: "Hello",
                                                                  with: "AvatarName")
                
                switch result {
                case .success(_):
                    print("Recording Start")
                    recordingTimer.startTimer()
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
                    case .loadDurationFailure:
                        print("loadDurationFailure")
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
                    case .loadDurationFailure:
                        print("loadDurationFailure")
                    }
                }
                recordingTimer.stopTimer()
            }.disposed(by: disposeBag)
        
        playingStartButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                
                if let recording = self.currentRecording {
                    let result = self.playingManager.startPlaying(url: recording.fileURL)
                    
                    switch result {
                    case .success:
                        print("Playing Start")
                        playingTimer.startTimer()
                    case .failure(let error):
                        switch error {
                        case .audioPlayerCreationFailure:
                            print("audioPlayerCreationFailure")
                        case .audioPlayerNotFound:
                            print("audioPlayerNotFound")
                        case .playingSessionSetupFailure:
                            print("playingSessionSetupFailure")
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
                        }
                    }
                    playingTimer.stopTimer()
                } else {
                    print("Recording Not Found")
                }
            }.disposed(by: disposeBag)
  
        recordingTime
            .subscribe(onNext: { [weak self] elapsedTime in
                guard let self else { return }
                
                let totalMilliseconds = Int(elapsedTime * 1000)
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
        
        playingTime
            .subscribe(onNext: { [weak self] elapsedTime in
                guard let self else { return }
                
                if let endTime = currentRecording?.duration, endTime <= elapsedTime {
                    playingTimer.stopTimer()
                } else {
                    let totalMilliseconds = Int(elapsedTime * 1000)
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
                }
            }).disposed(by: disposeBag)
        
        inputTextView.rx.text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self else { return }
                
                mailContents = text
                
            }).disposed(by: disposeBag)
        
        sendMailButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                if let url = self.serverSentFileURL {
                    print("url: \(url)")
                    
                    let result = self.playingManager.startPlaying(url: url)
                    
                    switch result {
                    case .success(()):
                        print("Succeed")
                    case .failure(let error):
                        switch error {
                        case .audioPlayerCreationFailure:
                            print("audioPlayerCreationFailure")
                        case .audioPlayerNotFound:
                            print("audioPlayerNotFound")
                        case .playingSessionSetupFailure:
                            print("playingSessionSetupFailure")
                        }
                    }
                } else {
                    print("No saved url.")
                }
                
            }.disposed(by: disposeBag)
        
        playServerSentFileButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                if let sampleText = mailContents, let fileURL = currentRecording?.fileURL {
                    uploadTextAndAudioFileToServer(text: sampleText, fileURL: fileURL, to: URL(string: "http://127.0.0.1:8000/upload")!)
                } else {
                    print("Data has not yet been set.")
                }
                
            }.disposed(by: disposeBag)
    }
}

extension SettingHomeController {
    func createBody(with parameters: [String: String]?, filePathKey: String, paths: [URL], boundary: String) -> Data {
        
        var body = Data()

        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }

        for path in paths {
            let filename = path.lastPathComponent
            let data = try! Data(contentsOf: path)
            let mimetype = "audio/m4a"

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func uploadTextAndAudioFileToServer(text: String, fileURL: URL, to url: URL) {
        
        print(text, String(describing: fileURL))
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let parameters = ["text": text]
        let paths = [fileURL]

        request.httpBody = createBody(with: parameters, filePathKey: "file", paths: paths, boundary: boundary)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentPath.appendingPathComponent("download.m4a")
            self.serverSentFileURL = fileURL
            
            print("\(fileURL) saved.")
            do {
                try data.write(to: fileURL)
            } catch {
                print("no server sent fileURL")
            }
        }
        task.resume()
    }
}


extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


extension SettingHomeController: CustomTimerDelegate {
    func timerUpdated(timerIdentifier: String, elapsedTime: Double) {
        switch timerIdentifier {
        case "RecordingTimer":
            recordingTime.onNext(elapsedTime)
        case "PlayingTimer":
            playingTime.onNext(elapsedTime)
        default: ()
        }
    }
}
