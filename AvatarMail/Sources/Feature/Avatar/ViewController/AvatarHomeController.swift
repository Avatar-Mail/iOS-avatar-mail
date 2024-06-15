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
    
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "나의 아바타"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
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
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            searchBar,
            placeholderView,
            collectionView
        )
        
        // title label
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        // searchBar
        searchBar.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(30)
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
        self.pageTitleLabel.text = "아바타 찾기"
    }
    
    func searchTextDidChange(text: String) {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: text))
    }
    
    func cancelButtonDidTap() {
        showAvatarSearchView(false)
        self.pageTitleLabel.text = "나의 아바타"
    }
    
    func clearButtonDidTap() {
        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: ""))
        showAvatarSearchView(true)
        searchBar.showKeyboard(true)
        self.pageTitleLabel.text = "아바타 찾기"
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

