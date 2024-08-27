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
    func changeToInputTextButtonDidTap()
    func randomTextSelectButtonDidTap()
    func changeSampleTextButtonDidTap()
    func inputTextSelectButtonDidTap()
    func selectAudioRecordingButtonDidTap()
    func selectFileUploadButtonDidTap()
    func recordingButtonDidTap(with recordingContents: String)
    func playingButtonDidTap(with recording: AudioRecording)
}

final class AvatarVoiceInputView: UIView {
    
    weak var delegate: AvatarVoiceInputViewDelegate?
    
    var disposeBag = DisposeBag()
    
    enum AvatarVoiceInputViewState {
        case initial
        case randomText
        case inputText
        case inputMethodChoice
        case inputVoice
    }
    
    enum RecordingButtonInnerShape {
        case circle
        case rectangle
    }
    
    private struct CollectionViewSetting {
        static let cellHeight: CGFloat = 116
        static let singleCellWidth: CGFloat = UIScreen.main.bounds.size.width - 2 * (20 + 16)
        static let multipleCellWidth: CGFloat = UIScreen.main.bounds.size.width - 2 * (20 + 16) - 16
        static let spacingBetweenCells: CGFloat = 10
    }
    
    private var viewState: AvatarVoiceInputViewState = .initial {
        didSet {
            showInitialStateView(viewState == .initial ? true : false)
            showRandomTextStateView(viewState == .randomText ? true : false)
            showInputTextStateView(viewState == .inputText ? true : false)
            showInputMethodSelectStateContainerView(viewState == .inputMethodChoice ? true : false)
            showInputVoiceStateView(viewState == .inputVoice ? true : false)
            
            
            switch viewState {
            case .initial:
                showBackButton(false)
                titleLabel.text = "아바타의 목소리를 입력하세요."
                subTitleLabel.text = "녹음 버튼을 눌러 아바타의 목소리를 녹음해보세요."
                
            case .randomText:
                showBackButton(true)
                titleLabel.text = "문장 선택"
                subTitleLabel.text = "어떤 문장을 녹음할 것인지 선택하세요."
                
            case .inputText:
                showBackButton(true)
                titleLabel.text = "문장 입력"
                subTitleLabel.text = "어떤 문장을 녹음할 것인지 입력하세요."
                
            case .inputMethodChoice:
                showBackButton(true)
                titleLabel.text = "음성 파일 추가"
                subTitleLabel.text = "아바타의 목소리를 녹음하거나, 음성 파일을 업로드 하세요."
                
                setContentLabel(with: recordingContents)
                
            case .inputVoice: ()
                showBackButton(true)
                titleLabel.text = "음성 녹음"
                subTitleLabel.text = "문장을 아바타의 목소리로 녹음하세요."
                
                setElaspedTimeLabels(with: 0.0)
                setContentLabel(with: recordingContents)
            }
        }
    }
    
    private var recordingList: [AudioRecording] = []  // 음성 녹음 파일 리스트
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
        $0.font = UIFont.content(size: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "음성 녹음 버튼을 눌러 아바타의 목소리를 녹음해보세요. 샘플 문장과 음성을 모두 입력해야 합니다."
        $0.font = UIFont.content(size: 14, weight: .regular)
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
    
    private let recordingsContainerView = UIView()
    
    private let recordingsPlaceHolderView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(hex: 0xEBEBEB, alpha: 0.6)
    }
    
    private let recordingsPlaceHolderLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "녹음된 음성 파일이 없습니다.",
                                                  color: UIColor(hex:0x7B7B7B),
                                                  font: .content(size: 14, weight: .regular))
    }
    
    private lazy var recordingsCollectionView = UICollectionView(frame: .zero,
                                                                 collectionViewLayout: self.recordingsCollectionViewFlowLayout).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.register(AudioRecordingCell.self, forCellWithReuseIdentifier: AudioRecordingCell.identifier)
        $0.isPrefetchingEnabled = false
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.decelerationRate = .fast
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var recordingsCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: CollectionViewSetting.multipleCellWidth,
                             height: CollectionViewSetting.cellHeight)
        $0.minimumLineSpacing = CollectionViewSetting.spacingBetweenCells
        $0.minimumInteritemSpacing = 0
    }
    
    private let initialAvatarVoiceRecordButton = UIButton().then {
        $0.setButtonTitle(title: "목소리 녹음하기",
                          color: .white,
                          font: .content(size: 16, weight: .bold))
        $0.applyCornerRadius(15)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    // 2. 랜덤 문장 입력 state 뷰
    private let randomTextStateContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let randomTextLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "녹음할 샘플 문장입니다.",
                                                  color: .black,
                                                  font: .content(size: 18, weight: .medium),
                                                  textAlignment: .center,
                                                  lineBreakMode: .byWordWrapping,
                                                  lineBreakStrategy: .hangulWordPriority)
        $0.numberOfLines = 0
    }
    
    let changeSampleTextButton = UIButton().then {
        
        var config = UIButton.Configuration.plain()
    
        var title = AttributedString("문장 바꾸기")
        title.font = UIFont.content(size: 14, weight: .regular)
        title.foregroundColor = UIColor(hex: 0xB6B6B6)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0xB6B6B6)
    }
    
    private let changeToInputTextButton = UIButton().then {
        $0.setButtonTitle(title: "직접 입력",
                          color: .gray,
                          font: .content(size: 14, weight: .bold))
    }
    
    private let randomTextSelectButton = UIButton().then {
        $0.setButtonTitle(title: "이 문장 선택하기",
                          color: .white,
                          font: .content(size: 16, weight: .bold))
        $0.applyCornerRadius(15)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    
    // 3. 사용자 정의 문장 입력 state 뷰
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
        $0.font = UIFont.content(size: 18, weight: .regular)
        $0.isScrollEnabled = false  // 스크롤을 비활성화하여 높이 자동 조정을 가능하게 함
    }
    
    // 글자수 레이블
    private let textCountLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "0 | 60자",
                                                  color: UIColor(hex:0x7B7B7B),
                                                  font: .content(size: 16, weight: .regular))
    }
    
    // 문장으로 녹음 시작 버튼
    private let inputTextSelectButton = UIButton().then {
        $0.setButtonTitle(title: "위 문장으로 녹음하기",
                          color: .white,
                          font: .content(size: 16, weight: .bold))
        $0.applyCornerRadius(15)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    // 4. 음성 녹음 / 파일 업로드 선택 state 뷰
    private let inputMethodSelectStateContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let contentsTextLabel1 = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let selectAudioRecordingButtonView = UIButton().then {
        $0.backgroundColor = .white
        $0.applyCornerRadius(20)
        $0.applyBorder(width: 2.5, color: UIColor(hex: 0x4C5BDF))
        $0.applyShadow(offset: CGSize(width: 0, height: 4))
    }
    
    private let selectAudioRecordingButtonIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "mic.fill")
        $0.tintColor = UIColor(hex:0x4C5BDF)
        $0.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    }
    
    private let selectAudioRecordingButtonTitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "음성 녹음",
                                                  color: .black,
                                                  font: .content(size: 18, weight: .semibold))
    }
    
    private let selectFileUploadButtonView = UIButton().then {
        $0.backgroundColor = .white
        $0.applyCornerRadius(20)
        $0.applyBorder(width: 2.5, color: UIColor(hex: 0x4C5BDF))
        $0.applyShadow(offset: CGSize(width: 0, height: 4))
    }
    
    private let selectFileUploadButtonIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "square.and.arrow.up.fill")
        $0.tintColor = UIColor(hex:0x4C5BDF)
        $0.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    }
    
    private let selectFileUploadButtonTitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "파일 업로드",
                                                  color: .black,
                                                  font: .content(size: 18, weight: .semibold))
    }
    
    // 5. 음성 녹음 state 뷰
    private let inputVoiceStateContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let contentsTextLabel2 = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let timerContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let minutesLabel = UILabel().then {
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
        $0.textAlignment = .center
    }
    
    private let firstColonLabel = UILabel().then {
        $0.text = ":"
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
        $0.textAlignment = .center
    }
    
    private let secondsLabel = UILabel().then {
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
        $0.textAlignment = .center
    }
    
    private let secondColonLabel = UILabel().then {
        $0.text = ":"
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
        $0.textAlignment = .center
    }
    
    private let millisecondsLabel = UILabel().then {
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex: 0x898989)
        $0.textAlignment = .center
    }
    
    private let recordingButtonInnerShape = UIView().then {
        $0.applyCornerRadius(30)
        $0.backgroundColor = UIColor(hex:0x6878F6)
    }
    
    private let recordingButton = UIButton().then {
        $0.applyCornerRadius(34)
        $0.applyBorder(width: 2, color: UIColor(hex:0xC9C9C9))
    }

    private let timer = CustomTimer(identifier: "AvatarVoiceInputViewTimer", interval: 0.01)
    
    private let recordingTime = BehaviorSubject<Double>(value: 0.0)
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
        
        timer.delegate = self
        recordingsCollectionView.delegate = self
        recordingsCollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        initialAvatarVoiceRecordButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                                        UIColor(hex: 0x4C5BDF)],
                                                               isHorizontal: true)
        
        inputTextSelectButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                               UIColor(hex: 0x4C5BDF)],
                                                         isHorizontal: true)
        
        randomTextSelectButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
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
        
        recordingList = recordings
        
        for subview in recordingsContainerView.subviews {
            subview.removeConstraints(subview.constraints)
            subview.removeFromSuperview()
        }
        
        // 녹음 파일이 없는 경우
        if recordings.isEmpty {
            // 플레이스 홀더 노출
            recordingsContainerView.addSubview(recordingsPlaceHolderView)
            recordingsPlaceHolderView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            recordingsPlaceHolderView.addSubview(recordingsPlaceHolderLabel)
            recordingsPlaceHolderLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        // 녹음 파일이 1개인 경우
        else if recordings.count == 1 {
            // 셀의 크기를 (Screen.width - 좌우 패딩) 값으로 수정
            let singleRecordingCollectionViewFloatLayout = UICollectionViewFlowLayout().then {
                $0.itemSize = CGSize(width: CollectionViewSetting.singleCellWidth,
                                     height: CollectionViewSetting.cellHeight)
                $0.minimumLineSpacing = 0
                $0.minimumInteritemSpacing = 0
            }
            recordingsCollectionView.collectionViewLayout = singleRecordingCollectionViewFloatLayout
            
            recordingsContainerView.addSubview(recordingsCollectionView)
            recordingsCollectionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        // 녹음 파일이 여러 개인 경우
        } else {
            let multipleRecordingsCollectionViewFloatLayout = UICollectionViewFlowLayout().then {
                $0.scrollDirection = .horizontal
                $0.itemSize = CGSize(width: CollectionViewSetting.multipleCellWidth,
                                     height: CollectionViewSetting.cellHeight)
                $0.minimumLineSpacing = CollectionViewSetting.spacingBetweenCells
                $0.minimumInteritemSpacing = 0
            }
            
            recordingsCollectionView.collectionViewLayout = multipleRecordingsCollectionViewFloatLayout
            
            recordingsContainerView.addSubview(recordingsCollectionView)
            recordingsCollectionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            recordingsContainerView.addSubview(recordingsCollectionView)
            recordingsCollectionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        recordingsCollectionView.reloadData()
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                backButton,
                
                subTitleLabel,
                
                contentsStackView.addArrangedSubViews(
                    
                    // 1. initial-state 뷰
                    initialStateContainerView.addSubViews(
                        recordingsContainerView,
                        initialAvatarVoiceRecordButton
                    ),
                    
                    // 2. randomText-state 뷰
                    randomTextStateContainerView.addSubViews(
                        // 랜덤 샘플 텍스트 레이블
                        randomTextLabel,
                        // 샘플 문장 변경 버튼
                        changeSampleTextButton,
                        // 직접 입력 버튼
                        changeToInputTextButton,
                        // 위 문장으로 입력하기 버튼
                        randomTextSelectButton
                    ),
                    
                    // 3. inputText-state 뷰
                    inputTextStateContainerView.addSubViews(
                        textViewContainerView.addSubViews(
                            inputTextView
                        ),
                        textCountLabel,
                        inputTextSelectButton
                    ),
                    
                    // 4. inputMethodChoice-state 뷰
                    inputMethodSelectStateContainerView.addSubViews(
                        // 음성 녹음 내용 레이블
                        contentsTextLabel1,
                        
                        // 음성 녹음 버튼
                        selectAudioRecordingButtonView.addSubViews(
                            selectAudioRecordingButtonIconImageView,
                            selectAudioRecordingButtonTitleLabel
                        ),
                        
                        // 파일 업로드 버튼
                        selectFileUploadButtonView.addSubViews(
                            selectFileUploadButtonIconImageView,
                            selectFileUploadButtonTitleLabel
                        )
                    ),
                    
                    // 5. inputVoice-state 뷰
                    inputVoiceStateContainerView.addSubViews(
                        // 음성 녹음 내용 레이블
                        contentsTextLabel2,
                        
                        // 녹음 시간 타이머 뷰
                        timerContainerView.addSubViews(
                            // 분 레이블
                            minutesLabel,
                            firstColonLabel,
                            // 초 레이블
                            secondsLabel,
                            secondColonLabel,
                            // 밀리초 레이블
                            millisecondsLabel
                        ),
                        
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
        
        // initial-state 뷰
        initialStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        recordingsContainerView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(116)
        }
        
        initialAvatarVoiceRecordButton.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        // randomText-state 뷰
        randomTextStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
         
        randomTextLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }
        
        changeSampleTextButton.snp.makeConstraints {
            $0.top.equalTo(randomTextLabel.snp.bottom).offset(6)
            $0.right.equalToSuperview()
        }
        
        changeToInputTextButton.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.height.equalTo(64)
            $0.width.equalTo(80)
        }
        
        randomTextSelectButton.snp.makeConstraints {
            $0.left.equalTo(changeToInputTextButton.snp.right).offset(16)
            $0.right.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        // inputText-state 뷰
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
        
        inputTextSelectButton.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        // inputMethodChoice-state 뷰
        inputMethodSelectStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        contentsTextLabel1.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }
        
        selectAudioRecordingButtonView.snp.makeConstraints {
            $0.right.equalTo(inputMethodSelectStateContainerView.snp.centerX).offset(-8)
            $0.left.bottom.equalToSuperview()
            $0.height.equalTo(85)
        }
        
        selectAudioRecordingButtonTitleLabel.snp.makeConstraints {
            $0.right.bottom.equalToSuperview().inset(18)
        }
        
        selectAudioRecordingButtonIconImageView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(25)
        }
        
        selectFileUploadButtonView.snp.makeConstraints {
            $0.left.equalTo(inputMethodSelectStateContainerView.snp.centerX).offset(8)
            $0.right.bottom.equalToSuperview()
            $0.height.equalTo(85)
        }
        
        selectFileUploadButtonTitleLabel.snp.makeConstraints {
            $0.right.bottom.equalToSuperview().inset(18)
        }
        
        selectFileUploadButtonIconImageView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(25)
        }
        
        // inputVoice-state 뷰
        inputVoiceStateContainerView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        contentsTextLabel2.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }
        
        timerContainerView.snp.makeConstraints {
            $0.bottom.equalTo(recordingButton.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
            $0.width.equalTo(150)
        }
        
        minutesLabel.snp.makeConstraints {
            $0.trailing.equalTo(firstColonLabel.snp.leading)
            $0.centerY.equalTo(secondsLabel.snp.centerY)
            $0.width.equalTo(20)
        }
        
        firstColonLabel.snp.makeConstraints {
            $0.trailing.equalTo(secondsLabel.snp.leading)
            $0.centerY.equalTo(secondsLabel.snp.centerY)
            $0.width.equalTo(5)
        }
        
        secondsLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(20)
        }
        
        secondColonLabel.snp.makeConstraints {
            $0.leading.equalTo(secondsLabel.snp.trailing)
            $0.centerY.equalTo(secondsLabel.snp.centerY)
            $0.width.equalTo(5)
        }
        
        millisecondsLabel.snp.makeConstraints {
            $0.leading.equalTo(secondColonLabel.snp.trailing)
            $0.centerY.equalTo(secondsLabel.snp.centerY)
            $0.width.equalTo(20)
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
        
        // 녹음 시간 바인딩
        recordingTime
            .subscribe(onNext: { [weak self] elapsedTime in
                guard let self else { return }
                
                setElaspedTimeLabels(with: elapsedTime)

            }).disposed(by: disposeBag)
        

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
        
        inputTextSelectButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                recordingContents = inputTextView.text
                delegate?.inputTextSelectButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        changeSampleTextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.changeSampleTextButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        changeToInputTextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.changeToInputTextButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        randomTextSelectButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                recordingContents = "\(randomTextLabel.text ?? "")"
                delegate?.randomTextSelectButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        inputTextView.rx.text
            .asDriver()
            .drive(onNext: { [weak self] text in
                guard let self else { return }
                setTextCountLabel(with: text?.count ?? 0)
            })
            .disposed(by: disposeBag)
        
        selectAudioRecordingButtonView.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.selectAudioRecordingButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        selectFileUploadButtonView.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.selectFileUploadButtonDidTap()
            }
            .disposed(by: disposeBag)
        
        recordingButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.recordingButtonDidTap(with: recordingContents)
            }
            .disposed(by: disposeBag)
    }
    
    private func setElaspedTimeLabels(with elapsedTime: Double) {
        
        let totalMilliseconds = Int(elapsedTime * 1000)
        let minutes = (totalMilliseconds / 1000) / 60
        let seconds = (totalMilliseconds / 1000) % 60
        let milliseconds = (totalMilliseconds % 1000) / 10
        
        minutesLabel.text = String(format: "%02d", minutes)
        secondsLabel.text = String(format: "%02d", seconds)
        millisecondsLabel.text = String(format: "%02d", milliseconds)
    }
    
    private func setContentLabel(with text: String) {
        contentsTextLabel1.attributedText = .makeAttributedString(text: text,
                                                                  color: .black,
                                                                  font: .content(size: 18, weight: .medium),
                                                                  textAlignment: .center,
                                                                  lineBreakMode: .byWordWrapping,
                                                                  lineBreakStrategy: .hangulWordPriority)
        contentsTextLabel2.attributedText = .makeAttributedString(text: text,
                                                                  color: .black,
                                                                  font: .content(size: 18, weight: .medium),
                                                                  textAlignment: .center,
                                                                  lineBreakMode: .byWordWrapping,
                                                                  lineBreakStrategy: .hangulWordPriority)
    }
    
    private func setTextCountLabel(with count: Int) {
        textCountLabel.attributedText = .makeAttributedString(text: "\(count) | 60자",
                                                              color: UIColor(hex:0x7B7B7B),
                                                              font: .content(size: 16, weight: .regular))
    }
    
    
    private func showInitialStateView(_ shouldShow: Bool) {
        initialStateContainerView.isHidden = !shouldShow
    }
    
    private func showRandomTextStateView(_ shouldShow: Bool) {
        randomTextStateContainerView.isHidden = !shouldShow
    }
    
    private func showInputTextStateView(_ shouldShow: Bool) {
        inputTextStateContainerView.isHidden = !shouldShow
    }
    
    private func showInputVoiceStateView(_ shouldShow: Bool) {
        inputVoiceStateContainerView.isHidden = !shouldShow
    }
    
    private func showInputMethodSelectStateContainerView(_ shouldShow: Bool) {
        inputMethodSelectStateContainerView.isHidden = !shouldShow
    }
    
    public func setViewState(_ state: AvatarVoiceInputViewState) {
        viewState = state
    }
    
    public func getViewState() -> AvatarVoiceInputViewState {
        return viewState
    }
    
    public func setSampleText(to text: String) {
        randomTextLabel.attributedText = .makeAttributedString(text: "\"\(text)\"",
                                                               color: .black,
                                                               font: .content(size: 18, weight: .medium),
                                                               textAlignment: .center,
                                                               lineBreakMode: .byWordWrapping,
                                                               lineBreakStrategy: .hangulWordPriority)
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
    
    public func startTimer() {
        timer.startTimer()
    }
    
    public func stopTimer() {
        timer.stopTimer()
    }
}


extension AvatarVoiceInputView: CustomTimerDelegate {
    func timerUpdated(timerIdentifier: String, elapsedTime: Double) {
        recordingTime.onNext(elapsedTime)
    }
}


extension AvatarVoiceInputView: AudioRecordingCellDelegate {
    func playingButtonDidTap(with recording: AudioRecording) {
        delegate?.playingButtonDidTap(with: recording)
    }
}


extension AvatarVoiceInputView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recordingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioRecordingCell.identifier, for: indexPath) as? AudioRecordingCell else {
            return UICollectionViewCell()
        }
        cell.setData(recording: recordingList[indexPath.row])
        cell.delegate = self
        return cell
    }
}


extension AvatarVoiceInputView: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, 
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let cellWidthIncludingSpacing = CollectionViewSetting.multipleCellWidth + CollectionViewSetting.spacingBetweenCells
        
        // targetContentOffset을 이용하여 x좌표가 얼마나 이동했는지 확인
        // 이동한 x좌표 값과 item의 크기를 비교하여 얼마나 페이징이 될 것인지를 계산
        var offset = targetContentOffset.pointee
        let index = (offset.x + recordingsCollectionView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        // scrollView, targetContentOffset의 좌표값으로 스크롤 방향을 알 수 있다.
        // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야지만 페이징 된다.
        
        // 셀 스크롤에 대한 예외 처리 (스크롤 시 셀이 반만 걸쳐있는 경우)
        if recordingsCollectionView.contentOffset.x > recordingsCollectionView.contentSize.width - frame.width {
            roundedIndex = ceil(index)
        } else if recordingsCollectionView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else if recordingsCollectionView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - recordingsCollectionView.contentInset.left, y: .zero)
        targetContentOffset.pointee = offset
    }
}
