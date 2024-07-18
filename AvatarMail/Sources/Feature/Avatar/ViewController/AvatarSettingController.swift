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
    
    private lazy var contentsCollectionView: UICollectionView = {
        let layout = makeFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hex: 0xEFEFEF)
        collectionView.register(AvatarNameInputCell.self, forCellWithReuseIdentifier: AvatarNameInputCell.identifier)
        collectionView.register(AvatarAgeInputCell.self, forCellWithReuseIdentifier: AvatarAgeInputCell.identifier)
        collectionView.register(AvatarRelationshipInputCell.self, forCellWithReuseIdentifier: AvatarRelationshipInputCell.identifier)
        collectionView.register(AvatarCharacteristicInputCell.self, forCellWithReuseIdentifier: AvatarCharacteristicInputCell.identifier)
        collectionView.register(AvatarParlanceInputCell.self, forCellWithReuseIdentifier: AvatarParlanceInputCell.identifier)
        return collectionView
    }()
    

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
    
    
    private var avatarSettingSections: [AvatarSettingSection] = [
        .avatarNameInput,
        .avatarAgeInput,
        .avatarRelationshipInput,
        .avatarCharacteristicInput,
        .avatarParlanceInput
    ]
    
    var dataSource: UICollectionViewDiffableDataSource<AvatarSettingSection, AvatarSettingItem>?
    
    
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
        setDelegates()
        configureDataSource()
        setAvatarInfo(reactor?.currentState.initialAvatarInfo)  // FIXME: 데이터를 받는 시점은 viewDidLoad 이전인데.. viewDidLoad 이후에 setAvatarInfo가 호출되어야 제대로 그려짐
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }
    
    
    private func setDelegates() {
        topNavigation.delegate = self
        contentsCollectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AvatarSettingSection, AvatarSettingItem>(collectionView: contentsCollectionView) { collectionView, indexPath, item in
            switch item {
            case .avatarNameInput(let name):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarNameInputCell.identifier,
                                                                    for: indexPath) as? AvatarNameInputCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.setData(name: name)
                return cell
            case .avatarAgeInput(let age):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarAgeInputCell.identifier,
                                                                    for: indexPath) as? AvatarAgeInputCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.setData(selectedChipData: age)
                return cell
            case .avatarRelationshipInput(let avatarRole, let userRole):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarRelationshipInputCell.identifier,
                                                                    for: indexPath) as? AvatarRelationshipInputCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.setData(avatarRole: avatarRole, userRole: userRole)
                return cell
            case .avatarCharacteristicInput(let characteristic):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCharacteristicInputCell.identifier,
                                                                    for: indexPath) as? AvatarCharacteristicInputCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.setData(characteristic: characteristic)
                return cell
            case .avatarParlanceInput(let parlance):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarParlanceInputCell.identifier,
                                                                    for: indexPath) as? AvatarParlanceInputCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.setData(parlance: parlance)
                return cell
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<AvatarSettingSection, AvatarSettingItem>()
        snapshot.appendSections(avatarSettingSections)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func setAvatarInfo(_ avatar: AvatarInfo?) {
        var snapshot = NSDiffableDataSourceSnapshot<AvatarSettingSection, AvatarSettingItem>()
        snapshot.appendSections(avatarSettingSections)
        
        snapshot.appendItems([.avatarNameInput(avatar?.name ?? "")], toSection: .avatarNameInput)
        snapshot.appendItems([.avatarAgeInput(avatar?.ageGroup ?? "")], toSection: .avatarAgeInput)
        snapshot.appendItems([.avatarRelationshipInput(avatar?.relationship.avatar ?? "", avatar?.relationship.user ?? "")], toSection: .avatarRelationshipInput)
        snapshot.appendItems([.avatarCharacteristicInput(avatar?.characteristic ?? "")], toSection: .avatarCharacteristicInput)
        snapshot.appendItems([.avatarParlanceInput(avatar?.parlance ?? "")], toSection: .avatarParlanceInput)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor(hex: 0xEBEBEB)
        
        view.addSubViews(
            topNavigation,
            contentsCollectionView,
            saveAvatarButtonContainer.addSubViews(saveAvatarButton)
        )
        
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        contentsCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
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
}

// MARK: AvatarNameInputCellDelegate
extension AvatarSettingController: AvatarNameInputCellDelegate {
    func nameInputTextFieldDidTap() {}
    
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
    func avatarRoleInputTextFieldDidTap() {}
    
    func avatarRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarSelfRoleDidChange(avatarRole: text))
    }
    
    func avatarRoleClearButtonDidTap() {}
    
    func userRoleInputTextFieldDidTap() {}
    
    func userRoleInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarUserRoleDidChange(userRole: text))
    }
    
    func userRoleClearButtonDidTap() {}
}

// MARK: AvatarCharacteristicInputCellDelegate
extension AvatarSettingController: AvatarCharacteristicInputCellDelegate {
    func characteristicInputTextViewDidTap() {}
    
    func characteristicInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarCharacteristicDidChange(characteristic: text))
    }
    
    func characteristicClearButtonDidTap() {}
}

// MARK: AvatarParlanceInputCellDelegate
extension AvatarSettingController: AvatarParlanceInputCellDelegate {
    func parlanceInputTextViewDidTap() {}
    
    func parlanceInputTextDidChange(text: String) {
        reactor?.action.onNext(.avatarParlanceDidChange(parlance: text))
    }
    
    func parlanceClearButtonDidTap() {}
}

// MARK: UIScrollViewDelegate
extension AvatarSettingController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AvatarSettingController {
    private func makeFlowLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] section, _ -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.makeSectionLayout(currentSection: self.avatarSettingSections[section])
        }
    }
    
    private func makeSectionLayout(currentSection: AvatarSettingSection) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // 마지막 섹션인 경우, '탭바 높이 + 16px' 하단 inset 적용
        if currentSection == .avatarParlanceInput {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 112, trailing: 0)
        } else {
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        }
        
        return section
    }
}

// Top Navigation Delegate 설정
extension AvatarSettingController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeAvatarSettingController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {}
    
    func topNavigationRightSideSecondaryIconDidTap() {}
    
    func topNavigationRightSideTextButtonDidTap() {}
}



extension AvatarSettingController: UICollectionViewDelegate {
    
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
