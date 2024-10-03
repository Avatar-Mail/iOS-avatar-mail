//
//  AvatarSettingController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/16/24.
//

import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import RxOptional
import ReactorKit
import Toast
import MobileCoreServices
import UniformTypeIdentifiers


class AvatarSettingController: UIViewController, View {
    
    typealias Reactor = AvatarSettingReactor
    
    var disposeBag = DisposeBag()
    
    private let topNavigation = TopNavigation().then {
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTitle(titleText: "아바타 설정하기", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
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
    
    // name input view
    private let avatarNameInputView = AvatarNameInputView()
    
    // age input view
    private let avatarAgeInputView = AvatarAgeInputView().then {
        $0.setData(selectedChipData: nil)
    }
    
    // relationship input view
    private let avatarRelationshipInputView = AvatarRelationshipInputView()
    
    // characteristic input view
    private let avatarCharacteristicInputView = AvatarCharacteristicInputView()
    
    // parlance input view
    private let avatarParlanceInputView = AvatarParlanceInputView()
    
    // voice input view
    private let avatarVoiceInputView = AvatarVoiceInputView()

    private let saveAvatarButtonContainerHeight: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 20) + 20 + 72
    private let saveAvatarButtonContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let saveAvatarButton = UIButton().then {
        $0.setButtonTitle(title: "아바타 설정하기",
                          color: .white,
                          font: .content(size: 20, weight: .bold))
        $0.applyCornerRadius(20)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }

    private var isSaveButtonContainerHidden = false

    
    init(reactor: AvatarSettingReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setUI()
        
        setDelegates()
        
        // 샘플 텍스트 json 파일 불러옴
        reactor?.action.onNext(.loadSampleTexts)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
        saveAvatarButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                            UIColor(hex: 0x4C5BDF)],
                                                 isHorizontal: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 페이지 이동 전 현재 실행 중인 오디오 파일 종료
        if let reactor, reactor.currentState.isPlaying == true {
            reactor.action.onNext(.stopPlaying)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let reactor else { return }
        
        // 아바타가 저장된 경우
        if reactor.currentState.hasAvatarSaved == true {
            // 임시 삭제 파일들을 실제로 파일 시스템에서 삭제
            reactor.action.onNext(.removeAllTempDeletedAudioFiles)
        }
        // 아바타가 저장되지 않은 경우
        else {
            // 임시 저장 파일들을 파일 시스템에서 삭제
            // ㄴ 음성 녹음이 끝난 직후 바로 파일 시스템에 추가되기 때문에, 실제로 아바타가 저장되지 않은 경우에는
            //    녹음된 파일들을 제거해야 한다.
            reactor.action.onNext(.removeAllTempSavedAudioFiles)
        }
    }
    
    
    private func setDelegates() {
        topNavigation.delegate = self
        
        avatarNameInputView.delegate = self
        avatarAgeInputView.delegate = self
        avatarRelationshipInputView.delegate = self
        avatarCharacteristicInputView.delegate = self
        avatarParlanceInputView.delegate = self
        avatarVoiceInputView.delegate = self
        
        pageScrollView.delegate = self
    }
    
    
    private func activateSpecificChildView(view: UIView?) {
        
        if let view {
            // 스택 뷰 안의 subview들과 비교
            for subview in contentStackView.arrangedSubviews {
                if let activatableSubview = subview as? ActivatableInputView {
                    if activatableSubview == view {
                        activatableSubview.activateInputView(true)
                    } else {
                        activatableSubview.activateInputView(false)
                    }
                }
            }
        }
        // 모든 자식 뷰를 비활성화 해야 하는 경우
        else {
            // 스택 뷰 안의 subview들 de-activate
            for subview in contentStackView.arrangedSubviews {
                if let activatableSubview = subview as? ActivatableInputView {
                    activatableSubview.activateInputView(false)
                }
            }
        }
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor(hex: 0xEBEBEB)
        
        view.addSubViews(
            topNavigation,
            
            pageScrollView.addSubViews(
                pageContentView.addSubViews(
                    contentStackView.addArrangedSubViews(
                        avatarNameInputView,
                        avatarAgeInputView,
                        avatarRelationshipInputView,
                        avatarCharacteristicInputView,
                        avatarParlanceInputView,
                        avatarVoiceInputView
                    )
                )
            ),
            
            saveAvatarButtonContainer.addSubViews(
                saveAvatarButton
            )
        )
        
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        // page scroll-view
        pageScrollView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // page scroll-view content area
        pageContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // page stack-view
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        contentStackView.directionalLayoutMargins = .init(top: 0,
                                                          leading: 0,
                                                          bottom: 92,
                                                          trailing: 0)
        
        saveAvatarButtonContainer.snp.makeConstraints {
            $0.height.equalTo(saveAvatarButtonContainerHeight)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(saveAvatarButtonContainerHeight)
        }
        
        saveAvatarButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(72)
        }
    }
    
    
    private func setUI() {
        guard let reactor else { return }
        
        avatarNameInputView.setData(name: reactor.initialState.name)
        avatarAgeInputView.setData(selectedChipData: reactor.initialState.age)
        avatarRelationshipInputView.setData(avatarRole: reactor.initialState.avatarRole,
                                            userRole: reactor.initialState.userRole)
        avatarCharacteristicInputView.setData(characteristic: reactor.initialState.characteristic)
        avatarParlanceInputView.setData(parlance: reactor.initialState.parlance)
        avatarVoiceInputView.setData(recordings: reactor.initialState.recordings)
    }
    
    
    func bind(reactor: AvatarSettingReactor) {
        reactor.state
            .observe(on: MainScheduler.asyncInstance)
            .map { $0.hasAvatarSaved }
            .distinctUntilChanged()
            .bind { [weak self] hasAvatarSaved in
                if hasAvatarSaved {
                    self?.reactor?.action.onNext(.closeAvatarSettingController)
                }
            }.disposed(by: disposeBag)
        
        reactor.pulse(\.$playingCellIndexPath)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .bind { [weak self] indexPath in
                guard let self else { return }
                // AudioRecordingCell 내 음성 재생 버튼 아이콘을 사각형 모양으로 변경 (재생 시작)
                avatarVoiceInputView.setPlayingButtonInnerShape(as: .rectangle, at: indexPath)
                // 현재 재생 중인 셀의 indexPath 설정
                avatarVoiceInputView.setPlayingCellIndexPath(as: indexPath)
            }.disposed(by: disposeBag)
        
        reactor.pulse(\.$stoppedPlayingCellIndexPath)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .bind { [weak self] indexPath in
                guard let self else { return }
                // AudioRecordingCell 내 음성 재생 버튼 아이콘을 삼각형 모양으로 변경 (재생 종료)
                avatarVoiceInputView.setPlayingButtonInnerShape(as: .triangle, at: indexPath)
                
                // 다른 셀이 아직 재생 중일 수도 있으므로,실제로 재생 종료 되었을 때 playingCellIndexPath를 nil로 설정
            }.disposed(by: disposeBag)
        
        reactor.pulse(\.$toastMessage)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.selectedSampleText)
            .distinctUntilChanged()
            .bind { [weak self] sampleText in
                guard let self else { return }
                avatarVoiceInputView.setSampleText(to: sampleText)
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.isRecording)
            .distinctUntilChanged()
            .bind { [weak self] isRecording in
                guard let self else { return }
                
                if isRecording == true {
                    avatarVoiceInputView.startTimer()
                    avatarVoiceInputView.setRecordingButtonInnerShape(as: .rectangle, animated: true)
                } else {
                    avatarVoiceInputView.stopTimer()
                    avatarVoiceInputView.setRecordingButtonInnerShape(as: .circle, animated: false)
                }
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.isPlaying)
            .skip(1)
            .distinctUntilChanged()
            .bind { [weak self] isPlaying in
                guard let self else { return }
                
                if isPlaying == true {
                    print("Start Playing")
                } else {
                    print("End Playing")
                    // 재생이 종료될 때 재생 playingCellIndexPath를 nil로 설정
                    avatarVoiceInputView.setPlayingCellIndexPath(as: nil)
                }
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.recordings)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] recordings in
                guard let self else { return }
                avatarVoiceInputView.setData(recordings: recordings)
                avatarVoiceInputView.setViewState(.initial) // FIXME: 녹음 실패 / 다운 실패 시 initial-state view로 돌아가지 않는 이슈 수정 필요
            }.disposed(by: disposeBag)
        
        
        saveAvatarButton.rx.tap
            .asDriver()
            .drive(onNext: {
                reactor.action.onNext(.saveAvatar)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: AvatarNameInputViewDelegate
extension AvatarSettingController: AvatarNameInputViewDelegate {
    func nameInputTextFieldDidTap() {
        activateSpecificChildView(view: avatarNameInputView)
    }
    
    func nameInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarNameDidChange(name: text))
    }
    
    func nameClearButtonDidTap() {}
}


// MARK: AvatarAgeInputViewDelegate
extension AvatarSettingController: AvatarAgeInputViewDelegate {
    func avatarAgeInputViewInnerChipDidTap(data: String) {
        reactor?.action.onNext(.avatarAgeDidChange(age: data))
    }
}


// MARK: AvatarRelationshipInputViewDelegate
extension AvatarSettingController: AvatarRelationshipInputViewDelegate {
    func avatarRoleInputTextFieldDidTap() {
        activateSpecificChildView(view: avatarRelationshipInputView)
    }
    
    func avatarRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarSelfRoleDidChange(avatarRole: text))
    }
    
    func avatarRoleClearButtonDidTap() {}
    
    func userRoleInputTextFieldDidTap() {
        activateSpecificChildView(view: avatarRelationshipInputView)
    }
    
    func userRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarUserRoleDidChange(userRole: text))
    }
    
    func userRoleClearButtonDidTap() {}
}


// MARK: AvatarCharacteristicInputViewDelegate
extension AvatarSettingController: AvatarCharacteristicInputViewDelegate {
    func characteristicInputTextViewDidTap() {
        activateSpecificChildView(view: avatarCharacteristicInputView)
    }
    
    func characteristicInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarCharacteristicDidChange(characteristic: text))
    }
    
    func characteristicClearButtonDidTap() {}
}


// MARK: AvatarParlanceInputViewDelegate
extension AvatarSettingController: AvatarParlanceInputViewDelegate {
    func parlanceInputTextViewDidTap() {
        activateSpecificChildView(view: avatarParlanceInputView)
    }
    
    func parlanceInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarParlanceDidChange(parlance: text))
    }
    
    func parlanceClearButtonDidTap() {}
}


// MARK: AvatarVoiceInputViewDelegate
extension AvatarSettingController: AvatarVoiceInputViewDelegate {

    func backButtonDidTap() {
        let viewState = avatarVoiceInputView.getViewState()
        avatarVoiceInputView.clearInputText()
        
        switch viewState {
        case .initial: ()
        case .randomText:
            avatarVoiceInputView.setViewState(.initial)
        case .inputText:
            avatarVoiceInputView.setViewState(.randomText)
        case .inputMethodChoice:
            avatarVoiceInputView.setViewState(.randomText)
        case .inputVoice: ()
            avatarVoiceInputView.setViewState(.inputMethodChoice)
        }
    }
    
    func initialAvatarVoiceRecordButtonDidTap() {
        reactor?.action.onNext(.changeSampleText)
        avatarVoiceInputView.setViewState(.randomText)
        
        // '목소리 녹음하기' 버튼을 클릭했을 때 현재 재생 중인 셀이 존재하는 경우, 재생 종료
        if let isPlaying = reactor?.currentState.isPlaying, isPlaying == true {
            reactor?.action.onNext(.stopPlaying)
            reactor?.action.onNext(.setPlayingCellIndexPath(indexPath: nil))
        }
    }
    
    func changeSampleTextButtonDidTap() {
        reactor?.action.onNext(.changeSampleText)
    }
    
    func changeToInputTextButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputText)
    }
    
    func randomTextSelectButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputMethodChoice)
    }
    
    func inputTextSelectButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputMethodChoice)
    }
    
    func selectAudioRecordingButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputVoice)
    }
    
    func selectFileUploadButtonDidTap() {
        selectAudioFile()
    }
    
    func recordingButtonDidTap(with recordingContents: String) {
        if let isRecording = reactor?.currentState.isRecording, isRecording == false {
            reactor?.action.onNext(.startRecording(recordingContents: recordingContents))
        } else {
            reactor?.action.onNext(.stopRecording)
        }
    }
    
    func playingButtonDidTap(with recording: AudioRecording, at indexPath: IndexPath) {
        if let isPlaying = reactor?.currentState.isPlaying, isPlaying == false {
            reactor?.action.onNext(.startPlaying(recording: recording))
            // 현재 재생 중인 셀 indexPath 설정
            reactor?.action.onNext(.setPlayingCellIndexPath(indexPath: indexPath))
        } else {
            guard let currentPlayingCellIndexPath = reactor?.currentState.playingCellIndexPath else {
                print("indexPath가 주어지지 않았습니다.")
                return
            }
            
            // 현재 재생 중인 셀의 음성 재생 버튼을 클릭한 경우
            if currentPlayingCellIndexPath == indexPath {
                reactor?.action.onNext(.stopPlaying)
                reactor?.action.onNext(.setPlayingCellIndexPath(indexPath: nil))
            }
            // 현재 재생 중이 아닌 다른 셀의 음성 재생 버튼을 클릭한 경우
            else {
                // 현재 재생 중인 음성 파일 종료
                reactor?.action.onNext(.stopPlaying)
                
                // 새로운 셀의 음성 파일 재생
                reactor?.action.onNext(.startPlaying(recording: recording))
                reactor?.action.onNext(.setPlayingCellIndexPath(indexPath: indexPath))
            }
        }
    }
    
    func deleteButtonDidTap(with recording: AudioRecording) {
        // 현재 재생 중인 셀이 존재하는 경우, 재생 종료
        if let isPlaying = reactor?.currentState.isPlaying, isPlaying == true {
            reactor?.action.onNext(.stopPlaying)
            reactor?.action.onNext(.setPlayingCellIndexPath(indexPath: nil))
        }
        
        GlobalDialog.shared.show(title: "파일을 삭제하시겠습니까?",
                                 description: "아바타 저장 이후 해당 파일이 삭제됩니다.",
                                 buttonInfos: .init(title: "취소", 
                                                    titleColor: UIColor(hex: 0x2B2B2B),
                                                    backgroundColor: UIColor(hex: 0xEDEDED),
                                                    borderColor: nil,
                                                    buttonHandler: {
                                                        GlobalDialog.shared.hide()
                                                    }),
                                              .init(title: "확인",
                                                    titleColor: .white,
                                                    backgroundColor: UIColor(hex: 0x336FF2),
                                                    borderColor: nil,
                                                    buttonHandler: { [weak self] in
                                                        guard let self else { return }
                                                        reactor?.action.onNext(.addToTempDeletedAudioFilesAndHide(fileName: recording.fileName))
                        
                                                        GlobalDialog.shared.hide()
                                                    }))
    }
}


// MARK: UIScrollViewDelegate
extension AvatarSettingController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activateSpecificChildView(view: nil)
        view.endEditing(true)  // 키보드 내림
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        let thresholdOffset: CGFloat = 150
        
        if scrollOffset > thresholdOffset && isSaveButtonContainerHidden {
            setSaveButtonContainerIsHidden(isHidden: false)
        } else if scrollOffset <= thresholdOffset && !isSaveButtonContainerHidden {
            setSaveButtonContainerIsHidden(isHidden: true)
        }
    }
    
    private func setSaveButtonContainerIsHidden(isHidden: Bool) {
        isSaveButtonContainerHidden = isHidden
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            if isHidden {
                // SaveButtonContainer를 디바이스 아래로 숨김
                self.saveAvatarButtonContainer.snp.updateConstraints {
                    $0.height.equalTo(self.saveAvatarButtonContainerHeight)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(self.saveAvatarButtonContainerHeight)
                }
            } else {
                // SaveButtonContainer를 원래 위치로 이동
                self.saveAvatarButtonContainer.snp.updateConstraints {
                    $0.height.equalTo(self.saveAvatarButtonContainerHeight)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalToSuperview()
                }
            }
            view.layoutIfNeeded()
        }
    }
}


//MARK: TopNavigationDelegate
extension AvatarSettingController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeAvatarSettingController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {}
    
    func topNavigationRightSideSecondaryIconDidTap() {}
    
    func topNavigationRightSideTextButtonDidTap() {}
}


//MARK: UIDocumentPickerDelegate (음성 파일 선택)
extension AvatarSettingController: UIDocumentPickerDelegate {
    
    // 오디오 파일 선택 메서드 (파일 선택 모달을 띄워줌)
    func selectAudioFile() {
        // iOS 14.0 이상에서는 UTTypeAudio 또는 UTType.audio 사용
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

    // 파일 선택 후 호출되는 메서드
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }

        guard avatarVoiceInputView.getRecordingContents().isNotEmpty else {
            reactor?.action.onNext(.showToast(text: "음성 파일과 매칭되는 문장(contents)이 설정되지 않았습니다."))
            return
        }
        
        // 주어진 URL 경로에 있는 음성 파일을 로컬에 저장
        reactor?.action.onNext(.downloadAudioFile(url: selectedFileURL,
                                                  contents: avatarVoiceInputView.getRecordingContents()))
    }
}
