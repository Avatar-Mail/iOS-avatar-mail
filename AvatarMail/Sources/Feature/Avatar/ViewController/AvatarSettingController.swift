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


class AvatarSettingController: UIViewController, View {
    
    typealias Reactor = AvatarSettingReactor
    
    var disposeBag = DisposeBag()
    
    private let topNavigation = TopNavigation().then {
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTitle(titleText: "아바타 설정하기", titleColor: .white, fontSize: 18, fontWeight: .semibold)
        $0.setRightSidePrimaryIcon(iconName: "bell.fill", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
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
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.setTitle("아바타 설정하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
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
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
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
            $0.horizontalEdges.equalToSuperview().inset(20)
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
        
        reactor.pulse(\.$toastMessage)
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.isRecording)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isRecording in
                guard let self else { return }
                
                if isRecording == true {
                    avatarVoiceInputView.startTimer()
                    avatarVoiceInputView.setRecordingButtonInnerShape(as: .rectangle, animated: true)
                } else {
                    avatarVoiceInputView.stopTimer()
                    avatarVoiceInputView.setRecordingButtonInnerShape(as: .circle, animated: false)
                    avatarVoiceInputView.setViewState(.initial)
                    
                }
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
        
        switch viewState {
        case .initial: ()
        case .inputText:
            avatarVoiceInputView.clearInputText()
            avatarVoiceInputView.setViewState(.initial)
        case .inputVoice: ()
            avatarVoiceInputView.setViewState(.inputText)
        }
    }
    
    func initialAvatarVoiceRecordButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputText)
    }
    
    func startRecordingTextButtonDidTap() {
        avatarVoiceInputView.setViewState(.inputVoice)
    }
    
    func recordingButtonDidTap(with recordingContents: String) {
        if let isRecording = reactor?.currentState.isRecording, isRecording == false {
            reactor?.action.onNext(.startRecording(recordingContents: recordingContents))
        } else {
            reactor?.action.onNext(.stopRecording)
        }
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
