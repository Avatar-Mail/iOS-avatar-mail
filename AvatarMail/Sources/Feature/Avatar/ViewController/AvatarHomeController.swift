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
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTitle(titleText: "아바타 찾기", titleColor: .white, fontSize: 18, fontWeight: .semibold)
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let searchBar = AvatarSearchBar()
    
    private let placeholderView = AvatarPlaceholderView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AvatarInfoCell.self, forCellWithReuseIdentifier: AvatarInfoCell.identifier)
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
        
        makeUI()
        
        searchBar.delegate = self
        placeholderView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 초기화
        searchBar.searchTextField.text = nil
        searchBar.showKeyboard(false)
        
        reactor?.action.onNext(.initializeAllStates)
        reactor?.action.onNext(.getAllAvatarInfos)
        
        showAvatarSearchView(false)
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
            searchBar,
            placeholderView,
            collectionView
        )
        
        // topNavigation
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
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
    }
    
    func bind(reactor: AvatarHomeReactor) {
        reactor.state
            .map { $0.filteredAvatarInfos }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items(cellIdentifier: AvatarInfoCell.identifier, cellType: AvatarInfoCell.self)) { index, avatar, cell in
                cell.setData(cellIndex: index, avatarName: avatar.name)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
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
        topNavigation.setTitle(titleText: "아바타 찾기", titleColor: .white, fontSize: 20, fontWeight: .semibold)
    }
    
    func searchTextDidChange(text: String) {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: text))
    }
    
    func cancelButtonDidTap() {
        showAvatarSearchView(false)
        topNavigation.setTitle(titleText: "나의 아바타", titleColor: .white, fontSize: 20, fontWeight: .semibold)
    }
    
    func clearButtonDidTap() {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: ""))
        showAvatarSearchView(true)
        searchBar.showKeyboard(true)
        topNavigation.setTitle(titleText: "아바타 찾기", titleColor: .white, fontSize: 20, fontWeight: .semibold)
    }
}


extension AvatarHomeController: AvatarPlaceholderViewDelegate {
    func createButtonDidTap() {
        reactor?.action.onNext(.showAvatarSettingController)
    }
}


extension AvatarHomeController: AvatarInfoCellDelegate {
    func avatarInfoCellDidTap(cellIndex: Int) {
        guard let filteredAvatars = reactor?.currentState.filteredAvatarInfos else {
            return
        }
        
        reactor?.action.onNext(.changeSelectedAvatar(avatar: filteredAvatars[cellIndex]))
        reactor?.action.onNext(.showAvatarSettingController)
    }
}

