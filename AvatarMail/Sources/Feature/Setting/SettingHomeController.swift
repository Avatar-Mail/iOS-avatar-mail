//
//  SettingHomeController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import AVFoundation

class SettingHomeController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var disposeBag = DisposeBag()
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    private var recordButton = UIButton().then {
        $0.setTitle("녹음 시작", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
    }
    
    private var playButton = UIButton().then {
        $0.setTitle("실행", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
    }
    
    private var textField = UITextField().then {
        $0.placeholder = "파일 이름 입력"
        $0.borderStyle = .roundedRect
    }
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setupRecorder()
        
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubview(pageTitleLabel)
        view.addSubview(recordButton)
        view.addSubview(textField)
        view.addSubview(playButton)
        
        // title label
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        // 녹음 버튼
        recordButton.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        // 텍스트 필드
        textField.snp.makeConstraints {
            $0.top.equalTo(recordButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
        
        // 실행 버튼
        playButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
    
    private func setupRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let url = getDocumentsDirectory().appendingPathComponent("a.m4a")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
        } catch {
            print("Failed to setup recorder: \(error)")
        }
    }
    
    @objc func recordButtonTapped() {
        if isRecording {
            audioRecorder.stop()
            recordButton.setTitle("녹음 시작", for: .normal)
        } else {
            audioRecorder.record()
            recordButton.setTitle("녹음 종료", for: .normal)
        }
        isRecording.toggle()
    }
    
    @objc func playButtonTapped() {
        if isPlaying {
            audioPlayer.stop()
            playButton.setTitle("실행", for: .normal)
        } else {
            guard let filename = textField.text, !filename.isEmpty else { return }
            let url = getDocumentsDirectory().appendingPathComponent("\(filename).m4a")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                audioPlayer.play()
                playButton.setTitle("중지", for: .normal)
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
        isPlaying.toggle()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("실행", for: .normal)
        isPlaying = false
    }
}
