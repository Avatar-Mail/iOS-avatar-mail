//
//  AvatarHomeController.swift
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
import ReactorKit


class AvatarHomeController: UIViewController, View {
    
    typealias Reactor = AvatarHomeReactor
    
    var disposeBag = DisposeBag()
    
    
    private let topNavigation = TopNavigation().then {
        $0.setLeftLogoIcon(logoName: "white_logo_img", logoSize: CGSize(width: 25, height: 25))
        $0.setRightSidePrimaryIcon(iconName: "bell.fill", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTitle(titleText: "나의 아바타", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let topNavigationBottomView = TopNavigationBottomView()
    
    private let searchBar = AvatarSearchBar()
    
    private let placeholderView = AvatarPlaceholderView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AutoCompletedNameCell.self, forCellWithReuseIdentifier: AutoCompletedNameCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isHidden = true
        return collectionView
    }()
    
    
    init(
        reactor: AvatarHomeReactor
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotifications()
        setDelegates()
        
        makeUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let isUncheckedReplyMailExists = UserDefaults.standard.object(forKey: AppConst.shared.isUncheckedReplyMailExists) as? Bool, isUncheckedReplyMailExists == true {
            // 미확인 편지가 존재하는 경우 Red dot 노출
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: false)
        } else {
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: true)
        }
        
        // 초기화
        searchBar.searchTextField.text = nil
        searchBar.showKeyboard(false)
        
        reactor?.action.onNext(.initializeAllStates)
        reactor?.action.onNext(.getAllAvatarInfos)
        
        showAvatarSearchView(false)
        
        tabBarController?.hideTabBar(isHidden: false, animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
    }
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            topNavigation,
            topNavigationBottomView,
            
            searchBar,
            placeholderView,
            collectionView
        )
        
        // topNavigation
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        // topNavigationBottomView
        topNavigationBottomView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(2)
            $0.right.equalToSuperview().inset(10)
        }
        
        // searchBar
        searchBar.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(30)
            $0.height.equalTo(45)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // avatar placeholder view
        placeholderView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.height ?? 90))
        }
        
        // collection view
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.height ?? 90))
        }
        
        view.bringSubviewToFront(topNavigationBottomView)
    }
    
    func bind(reactor: AvatarHomeReactor) {
        reactor.state
            .map { $0.filteredAvatarInfos }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items(cellIdentifier: AutoCompletedNameCell.identifier,
                                              cellType: AutoCompletedNameCell.self)) { index, avatar, cell in
                cell.setData(cellIndex: index, avatarName: avatar.name)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
    
    
    private func setDelegates() {
        searchBar.delegate = self
        placeholderView.delegate = self
        topNavigation.delegate = self
    }
    
    
    private func setNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(replyMailReceived),
                                               name: .replyMailReceived,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(replyMailChecked),
                                               name: .replyMailChecked,
                                               object: nil)
    }
    
    
    @objc private func replyMailReceived() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: false)
            topNavigationBottomView.showTopNavigationBottomView(withText: "새로운 편지가 도착했어요!")
        }
    }
    
    
    @objc private func replyMailChecked() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: true)
        }
    }
    
    
    private func showAvatarSearchView(_ shouldShow: Bool) {
        if shouldShow {
            placeholderView.isHidden = true
            collectionView.isHidden = false
        } else {
            placeholderView.isHidden = false
            collectionView.isHidden = true
        }
    }
}


extension AvatarHomeController: AvatarSearchBarDelegate {
    func searchTextFieldDidTap() {
        showAvatarSearchView(true)
        topNavigation.setTitle(titleText: "아바타 찾기", titleColor: .white, font: .content(size: 18, weight: .semibold))
    }
    
    func searchTextDidChange(text: String) {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: text))
    }
    
    func cancelButtonDidTap() {
        showAvatarSearchView(false)
        topNavigation.setTitle(titleText: "나의 아바타", titleColor: .white, font: .content(size: 18, weight: .semibold))
    }
    
    func clearButtonDidTap() {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: ""))
        showAvatarSearchView(true)
        searchBar.showKeyboard(true)
        topNavigation.setTitle(titleText: "나의 아바타", titleColor: .white, font: .content(size: 18, weight: .semibold))
    }
}


extension AvatarHomeController: AvatarPlaceholderViewDelegate {
    func createButtonDidTap() {
        reactor?.action.onNext(.showAvatarSettingController)
    }
}


extension AvatarHomeController: AutoCompletedNameCellDelegate {
    func autoCompletedNameCellDidTap(cellIndex: Int) {
        guard let filteredAvatars = reactor?.currentState.filteredAvatarInfos else {
            return
        }
        
        reactor?.action.onNext(.changeSelectedAvatar(avatar: filteredAvatars[cellIndex]))
        reactor?.action.onNext(.showAvatarSettingController)
    }
}


extension AvatarHomeController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {
        if let isUncheckedReplyMailExists = UserDefaults.standard.object(forKey: AppConst.shared.isUncheckedReplyMailExists) as? Bool, isUncheckedReplyMailExists == true {
            topNavigationBottomView.showTopNavigationBottomView(withText: "아직 읽지 않은 편지가 있어요!\n편지함을 확인해보세요~!")
        } else {
            topNavigationBottomView.showTopNavigationBottomView(withText: "아직 도착한 편지가 없어요!")
        }
    }
    
    func topNavigationRightSideSecondaryIconDidTap() {
        
    }
    
    func topNavigationRightSideTextButtonDidTap() {
        
    }
}
