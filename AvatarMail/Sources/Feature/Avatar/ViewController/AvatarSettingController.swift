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
    
    // title container
    private let pageTitleContainerView = UIView().then {
        $0.backgroundColor = .white
        
        // 왼쪽, 오른쪽 하단에만 cornerRadius 적용
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
    // title label
    private let pageTitleLabel = UILabel().then {
        $0.text = "아바타 설정"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .white
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
        $0.alignment = .center
        $0.backgroundColor = .clear
        $0.spacing = 20
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
    
    
    // save button
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
    
    
    init(
        reactor: AvatarSettingReactor
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setDelegates()
    }
    
    
    public func setAvatarInfo(_ avatar: AvatarInfo) {
        avatarNameInputView.setData(name: avatar.name)
        avatarAgeInputView.setData(selectedChipData: avatar.ageGroup)
        avatarRelationshipInputView.setData(avatarRole: avatar.relationship.avatar,
                                            userRole: avatar.relationship.user)
        avatarCharacteristicInputView.setData(characteristic: avatar.characteristic)
        avatarParlanceInputView.setData(parlance: avatar.parlance)
    }
    
    
    private func setDelegates() {
        avatarNameInputView.delegate = self
        avatarAgeInputView.delegate = self
        avatarRelationshipInputView.delegate = self
        avatarCharacteristicInputView.delegate = self
        avatarParlanceInputView.delegate = self
        
        pageScrollView.delegate = self
    }
    
    
    private func makeUI() {
        view.backgroundColor = UIColor(hex: 0xEBEBEB)
        
        view.addSubViews(
            pageTitleContainerView.addSubViews(
                pageTitleLabel
            ),
            
            pageScrollView.addSubViews(
                pageContentView.addSubViews(
                    contentStackView.addArrangedSubViews(
                        avatarNameInputView,
                        avatarAgeInputView,
                        avatarRelationshipInputView,
                        avatarCharacteristicInputView,
                        avatarParlanceInputView,
                        saveAvatarButton
                    )
                )
            )
        )
        
        // title label
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        // title container view
        pageTitleContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(pageTitleLabel.snp.bottom).offset(20)
        }
        
        // page scroll-view
        pageScrollView.snp.makeConstraints {
            $0.top.equalTo(pageTitleContainerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.height ?? 90))
        }
        
        // page scroll-view content area
        pageContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // page stack-view
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        // save button
        saveAvatarButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {

        // title container-view background gradient
        let gradient = CAGradientLayer()
        gradient.frame = pageTitleContainerView.bounds
        gradient.colors = [UIColor(hex: 0xD71204).cgColor, UIColor(hex: 0xF8554A).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        pageTitleContainerView.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func bind(reactor: AvatarSettingReactor) {
        // 최초 뷰 데이터 세팅
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.initialAvatarInfo }
            .filterNil()
            .distinctUntilChanged()
            .bind { [weak self] avatarInfo in
                guard let self else { return }
                self.setAvatarInfo(avatarInfo)
            }.disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.asyncInstance)
            .map { $0.hasAvatarSaved }
            .distinctUntilChanged()
            .bind { hasAvatarSaved in
                if hasAvatarSaved {
                    reactor.action.onNext(.closeAvatarSettingController)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.asyncInstance)
            .map { $0.toastMessage }
            .distinctUntilChanged()
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
        
        saveAvatarButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.saveAvatarButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
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
    func avatarAgeInputViewChipDidTap(data: String) {
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


// MARK: UIScrollViewDelegate
extension AvatarSettingController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activateSpecificChildView(view: nil)
        view.endEditing(true)  // 키보드 내림
    }
}

