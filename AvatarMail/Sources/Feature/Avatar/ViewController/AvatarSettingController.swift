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
        $0.setLeftLogoIcon(logoName: "white_logo_img", logoSize: CGSize(width: 25, height: 25))
        $0.setTitle(titleText: "아바타 설정하기", titleColor: .white, fontSize: 18, fontWeight: .semibold)
        $0.setRightSidePrimaryIcon(iconName: "bell.fill", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private lazy var  contentsCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout()).then {
            $0.backgroundColor = UIColor(hex: 0xEFEFEF)
            $0.register(AvatarNameInputCell.self, forCellWithReuseIdentifier: AvatarNameInputCell.identifier)
            $0.register(AvatarAgeInputCell.self, forCellWithReuseIdentifier: AvatarAgeInputCell.identifier)
            $0.register(AvatarRelationshipInputCell.self, forCellWithReuseIdentifier: AvatarRelationshipInputCell.identifier)
            $0.register(AvatarCharacteristicInputCell.self, forCellWithReuseIdentifier: AvatarCharacteristicInputCell.identifier)
            $0.register(AvatarParlanceInputCell.self, forCellWithReuseIdentifier: AvatarParlanceInputCell.identifier)
        }
        return collectionView
    }()
    
    private var avatarSettingSections: [AvatarSettingSection] = [
        .avatarNameInput,
        .avatarAgeInput,
        .avatarRelationshipInput,
        .avatarCharacteristicInput,
        .avatarParlanceInput
    ]
    
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
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        self.contentsCollectionView.dataSource = self
        // self.contentsCollectionView.delegate = self
    }
    
    
    public func setAvatarInfo(_ avatar: AvatarInfo) {
//        avatarNameInputView.setData(name: avatar.name)
//        avatarAgeInputView.setData(selectedChipData: avatar.ageGroup)
//        avatarRelationshipInputView.setData(avatarRole: avatar.relationship.avatar,
//                                            userRole: avatar.relationship.user)
//        avatarCharacteristicInputView.setData(characteristic: avatar.characteristic)
//        avatarParlanceInputView.setData(parlance: avatar.parlance)
    }
    
    
    private func makeUI() {
        view.backgroundColor = UIColor(hex: 0xEBEBEB)
        
        view.addSubViews(
            topNavigation,
            contentsCollectionView
        )
        
        // topNavigation
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        // collection-view
        contentsCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
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

    
//    private func activateSpecificChildView(view: UIView?) {
//        
//        if let view {
//            // 스택 뷰 안의 subview들과 비교
//            for subview in contentStackView.arrangedSubviews {
//                if let activatableSubview = subview as? ActivatableInputView {
//                    if activatableSubview == view {
//                        activatableSubview.activateInputView(true)
//                    } else {
//                        activatableSubview.activateInputView(false)
//                    }
//                }
//            }
//        }
//        // 모든 자식 뷰를 비활성화 해야 하는 경우
//        else {
//            // 스택 뷰 안의 subview들 de-activate
//            for subview in contentStackView.arrangedSubviews {
//                if let activatableSubview = subview as? ActivatableInputView {
//                    activatableSubview.activateInputView(false)
//                }
//            }
//        }
//    }
}


// MARK: AvatarNameInputCellDelegate
extension AvatarSettingController: AvatarNameInputCellDelegate {
    func nameInputTextFieldDidTap() {
        // activateSpecificChildView(view: avatarNameInputView)
    }
    
    func nameInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarNameDidChange(name: text))
    }
    
    func nameClearButtonDidTap() {}
}


// MARK: AvatarAgeInputCellDelegate
extension AvatarSettingController: AvatarAgeInputCellDelegate {
    func avatarAgeInputCellInnerChipDidTap(data: String) {
        reactor?.action.onNext(.avatarAgeDidChange(age: data))
    }
}


// MARK: AvatarRelationshipInputCellDelegate
extension AvatarSettingController: AvatarRelationshipInputCellDelegate {
    func avatarRoleInputTextFieldDidTap() {
        // activateSpecificChildView(view: avatarRelationshipInputView)
    }
    
    func avatarRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarSelfRoleDidChange(avatarRole: text))
    }
    
    func avatarRoleClearButtonDidTap() {}
    
    func userRoleInputTextFieldDidTap() {
        // activateSpecificChildView(view: avatarRelationshipInputView)
    }
    
    func userRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarUserRoleDidChange(userRole: text))
    }
    
    func userRoleClearButtonDidTap() {}
}


// MARK: AvatarCharacteristicInputViewDelegate
extension AvatarSettingController: AvatarCharacteristicInputCellDelegate {
    func characteristicInputTextViewDidTap() {
        // activateSpecificChildView(view: avatarCharacteristicInputView)
    }
    
    func characteristicInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarCharacteristicDidChange(characteristic: text))
    }
    
    func characteristicClearButtonDidTap() {}
}


// MARK: AvatarParlanceInputViewDelegate
extension AvatarSettingController: AvatarParlanceInputCellDelegate {
    func parlanceInputTextViewDidTap() {
        // activateSpecificChildView(view: avatarParlanceInputView)
    }
    
    func parlanceInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarParlanceDidChange(parlance: text))
    }
    
    func parlanceClearButtonDidTap() {}
}


// MARK: UIScrollViewDelegate
extension AvatarSettingController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // activateSpecificChildView(view: nil)
        view.endEditing(true)  // 키보드 내림
    }
}


extension AvatarSettingController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return avatarSettingSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch avatarSettingSections[section] {
        case .avatarNameInput:
            return 1
        case .avatarAgeInput:
            return 1
        case .avatarRelationshipInput:
            return 1
        case .avatarCharacteristicInput:
            return 1
        case .avatarParlanceInput:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch avatarSettingSections[indexPath.section] {
        case .avatarNameInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarNameInputCell.identifier, for: indexPath) as! AvatarNameInputCell
            cell.delegate = self
            return cell
        case .avatarAgeInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarAgeInputCell.identifier, for: indexPath) as! AvatarAgeInputCell
            cell.delegate = self
            return cell
        case .avatarRelationshipInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarRelationshipInputCell.identifier, for: indexPath) as! AvatarRelationshipInputCell
            cell.delegate = self
            return cell
        case .avatarCharacteristicInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCharacteristicInputCell.identifier, for: indexPath) as! AvatarCharacteristicInputCell
            cell.delegate = self
            return cell
        case .avatarParlanceInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarParlanceInputCell.identifier, for: indexPath) as! AvatarParlanceInputCell
            cell.delegate = self
            return cell
        }
    }
}



extension AvatarSettingController {
    private func makeFlowLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, ev -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            // section에 따라 서로 다른 layout 구성
            return self.makeSectionLayout(currentSection: self.avatarSettingSections[section])
        }
    }
    
    // '편지 작성하기' 섹션 레이아웃 생성
    private func makeSectionLayout(currentSection: AvatarSettingSection) -> NSCollectionLayoutSection? {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 16,
                                                     bottom: 0,
                                                     trailing: 16)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        // section.orthogonalScrollingBehavior = .continuous // Horizontal scrolling
        section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                        leading: 0,
                                                        bottom: 0,
                                                        trailing: 0)
        
        return section
    }
    
    // '편지 작성하기' 섹션 레이아웃 생성
    private func makeAvatarAgeInputSectionLayout() -> NSCollectionLayoutSection? {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 16,
                                                     bottom: 0,
                                                     trailing: 16)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        // section.orthogonalScrollingBehavior = .continuous // Horizontal scrolling
        section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                        leading: 0,
                                                        bottom: 0,
                                                        trailing: 0)
        
        return section
    }
}
