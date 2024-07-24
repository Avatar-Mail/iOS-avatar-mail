//
//  AvatarVoiceInputView.swift
//  AvatarMail
//
//  Created by 최지석 on 7/21/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit

protocol AvatarVoiceInputViewDelegate: AnyObject {
    func backButtonDidTap()
    func initialAvatarVoiceRecordButtonDidTap()
    func startRecordingTextButtonDidTap()
    func recordingButtonDidTap()
}

final class AvatarVoiceInputView: UIView {
    
    weak var delegate: AvatarVoiceInputViewDelegate?
    
    var disposeBag = DisposeBag()
    
    enum AvatarVoiceInputViewState {
        case initial
        case inputText
        case inputVoice
    }
    
    enum RecordingButtonInnerShape {
        case circle
        case rectangle
    }
    
    private var viewState: AvatarVoiceInputViewState = .initial {
        didSet {
            showInitialStateView(viewState == .initial ? true : false)
            showInputTextStateView(viewState == .inputText ? true : false)
            showInputVoiceStateView(viewState == .inputVoice ? true : false)
            
            switch viewState {
            case .initial:
                showBackButton(false)
                titleLabel.text = "아바타의 목소리를 입력하세요."
                subTitleLabel.text = "음성 녹음 버튼을 눌러 아바타의 목소리를 녹음해보세요. 샘플 문장과 음성을 모두 입력해야 합니다."
            case .inputText:
                showBackButton(true)
                titleLabel.text = "문장 입력"
                subTitleLabel.text = "어떤 문장을 녹음할 것인지 입력하세요."
            case .inputVoice: ()
                titleLabel.text = "음성 녹음"
                subTitleLabel.text = "문장을 아바타의 목소리로 녹음하세요."
                
                contentsTextLabel.attributedText = .makeAttributedString(text: "\"\(recordingContents)\"",
                                                                         color: .black,
                                                                         fontSize: 20)
                contentsTextLabel.textAlignment = .center
            }
        }
    }
    
    private var recordingContents: String = ""
    
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "아바타의 목소리를 입력하세요."
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "음성 녹음 버튼을 눌러 아바타의 목소리를 녹음해보세요. 샘플 문장과 음성을 모두 입력해야 합니다."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .lightGray
        $0.lineBreakMode = .byCharWrapping
    }
    
    private let backButton = UIButton().then {
        var config = UIButton.Configuration.plain()

        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
        let image = UIImage(systemName: "arrow.uturn.backward", withConfiguration: imageConfiguration)
        config.image = image
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0x818181)
    }
    
    private let contentsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.backgroundColor = .clear
        $0.spacing = 0
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    // 1. 최초 state 뷰
    private let initialStateContainerView = UIView()
    
    private let initialAvatarVoiceRecordButton = UIButton().then {
        $0.setButtonTitle(title: "목소리 녹음하기",
                          color: .white,
                          fontSize: 16,
                          fontWeight: .bold)
        $0.applyCornerRadius(15)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    // 2. 문장 입력 state 뷰
    private let inputTextStateContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let textViewContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let inputTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.isScrollEnabled = false  // 스크롤을 비활성화하여 높이 자동 조정을 가능하게 함
    }
    
    // 글자수 레이블
    private let textCountLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "0 | 60자",
                                                  color: UIColor(hex:0x7B7B7B),
                                                  fontSize: 16,
                                                  fontWeight: .regular)
    }
    
    // 문장으로 녹음 시작 버튼
    private let startRecordingTextButton = UIButton().then {
        $0.setButtonTitle(title: "위 문장으로 녹음하기",
                          color: .white,
                          fontSize: 16,
                          fontWeight: .bold)
        $0.applyCornerRadius(15)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    // 3. 음성 녹음 state 뷰
    private let inputVoiceStateContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let contentsTextLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let minutesLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
    }
    
    private let firstColonLabel = UILabel().then {
        $0.text = ":"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
    }
    
    private let secondsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
    }
    
    private let secondColonLabel = UILabel().then {
        $0.text = ":"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
    }
    
    private let millisecondsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
    }
    
    private let recordingButtonInnerShape = UIView().then {
        $0.applyCornerRadius(30)
        $0.backgroundColor = UIColor(hex:0x6878F6)
    }
    
    private let recordingButton = UIButton().then {
        $0.applyCornerRadius(34)
        $0.applyBorder(width: 2, color: UIColor(hex:0xC9C9C9))
    }

    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        initialAvatarVoiceRecordButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                                        UIColor(hex: 0x4C5BDF)],
                                                               isHorizontal: true)
        
        startRecordingTextButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                                  UIColor(hex: 0x4C5BDF)],
                                                         isHorizontal: true)
    }
    
    
    private func showBackButton(_ shouldShow: Bool) {
        if shouldShow {
            backButton.isHidden = false
        } else {
            backButton.isHidden = true
        }
    }
    
    
    public func clearInputText() {
        inputTextView.text = nil
    }
    
    public func setData(recordings: [AudioRecording]) {
        // TODO: 아바타 녹음 파일 컬렉션 뷰 표시
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                backButton,
                
                subTitleLabel,
                
                contentsStackView.addArrangedSubViews(
                    
                    // initial-state 뷰
                    initialStateContainerView.addSubViews(
                        initialAvatarVoiceRecordButton
                    ),
                    
                    // inputText-state 뷰
                    inputTextStateContainerView.addSubViews(
                        textViewContainerView.addSubViews(
                            inputTextView
                        ),
                        textCountLabel,
                        startRecordingTextButton
                    ),
                    
                    // inputVoice-state 뷰
                    inputVoiceStateContainerView.addSubViews(
                        // 음성 녹음 내용 레이블
                        contentsTextLabel,
                        
                        // 분 레이블
                        minutesLabel,
                        firstColonLabel,
                        // 초 레이블
                        secondsLabel,
                        secondColonLabel,
                        // 밀리초 레이블
                        millisecondsLabel,
                        
                        // 음성 녹음 버튼
                        recordingButtonInnerShape,
                        recordingButton
                    )
                    
                )
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(backButton.snp.leading).inset(10)
        }
        
        
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY).offset(-2)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(25)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentsStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            $0.left.bottom.right.equalToSuperview().inset(20)
        }
        
        initialAvatarVoiceRecordButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        inputTextStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        textViewContainerView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        inputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(textViewContainerView.snp.bottom).offset(10)
            $0.right.equalToSuperview()
        }
        
        startRecordingTextButton.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        inputVoiceStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        contentsTextLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }
        
        recordingButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(68)
        }
        
        recordingButtonInnerShape.snp.makeConstraints {
            $0.size.equalTo(60)
            $0.center.equalTo(recordingButton.snp.center)
        }
    }
    
    
    private func bindUI() {
        backButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.backButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        initialAvatarVoiceRecordButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.initialAvatarVoiceRecordButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        startRecordingTextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.startRecordingTextButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        inputTextView.rx.text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self else { return }
                
                recordingContents = text ?? ""
                
                textCountLabel.attributedText = .makeAttributedString(text: "\(recordingContents.count) | 60자",
                                                                      color: UIColor(hex:0x7B7B7B),
                                                                      fontSize: 16,
                                                                      fontWeight: .regular)
            })
            .disposed(by: disposeBag)
        
        recordingButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.recordingButtonDidTap()
            }
            .disposed(by: disposeBag)
    }
    
    
    private func showInitialStateView(_ shouldShow: Bool) {
        initialStateContainerView.isHidden = !shouldShow
    
    }
    
    private func showInputTextStateView(_ shouldShow: Bool) {
        inputTextStateContainerView.isHidden = !shouldShow
    }
    
    private func showInputVoiceStateView(_ shouldShow: Bool) {
        inputVoiceStateContainerView.isHidden = !shouldShow
    }
    
    public func setViewState(_ state: AvatarVoiceInputViewState) {
        viewState = state
    }
    
    public func getViewState() -> AvatarVoiceInputViewState {
        return viewState
    }
    
    public func isRecordingContentsEmpty() -> Bool {
        return recordingContents.isEmpty
    }
    
    public func setRecordingButtonInnerShape(as shape: RecordingButtonInnerShape, animated: Bool) {
        let cornerRadius: CGFloat
        let newSize: CGSize
        
        switch shape {
        case .circle:
            cornerRadius = 30
            newSize = CGSize(width: 60, height: 60)
        case .rectangle:
            cornerRadius = 5
            newSize = CGSize(width: 25, height: 25)
        }
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7) { [weak self] in
                guard let self else { return }
                recordingButtonInnerShape.layer.cornerRadius = cornerRadius
                recordingButtonInnerShape.snp.updateConstraints {
                    $0.size.equalTo(newSize)
                }
                layoutIfNeeded()
            }
            animator.startAnimation()
        } else {
            recordingButtonInnerShape.layer.cornerRadius = cornerRadius
            recordingButtonInnerShape.snp.updateConstraints {
                $0.size.equalTo(newSize)
            }
            layoutIfNeeded()
        }
    }
}


