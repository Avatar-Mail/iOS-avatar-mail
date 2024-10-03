//
//  MailHomeController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit


class MailHomeController: UIViewController, View {
    
    typealias Reactor = MailHomeReactor

    var disposeBag = DisposeBag()
    
    
    private let topNavigation = TopNavigation().then {
        $0.setLeftLogoIcon(logoName: "white_logo_img", logoSize: CGSize(width: 25, height: 25))
        $0.setRightSidePrimaryIcon(iconName: "bell.fill", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let topNavigationBottomView = TopNavigationBottomView()

    private lazy var  contentsCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout()).then {
            $0.backgroundColor = UIColor(hex: 0xEFEFEF)
            $0.register(WriteMailCell.self, forCellWithReuseIdentifier: WriteMailCell.identifier)
            $0.register(CheckMailboxCell.self, forCellWithReuseIdentifier: CheckMailboxCell.identifier)
        }
        return collectionView
    }()
    
    private var mailHomeSections: [MailHomeSection] = [
        MailHomeSection.writeMail,
        MailHomeSection.checkMailbox
    ]
    
    
    init(
        reactor: MailHomeReactor
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
        setupCollectionView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let isUncheckedReplyMailExists = UserDefaults.standard.object(forKey: AppConst.shared.isUncheckedReplyMailExists) as? Bool, isUncheckedReplyMailExists == true {
            // 미확인 편지가 존재하는 경우 Red dot 노출
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: false)
        } else {
            topNavigation.setTopNavigationRightSidePrimaryIconRedDot(isHidden: true)
        }
        
        tabBarController?.hideTabBar(isHidden: false, animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
    }
    
    
    private func makeUI() {
        view.addSubViews(
            topNavigation,
            topNavigationBottomView,
            contentsCollectionView
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
        
        // collection-view
        contentsCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        view.bringSubviewToFront(topNavigation)
        view.bringSubviewToFront(topNavigationBottomView)
    }
    
    
    func bind(reactor: MailHomeReactor) {}
    
    
    private func setupCollectionView() {
        self.contentsCollectionView.dataSource = self
        // self.contentsCollectionView.delegate = self
    }
    
    
    private func setDelegates() {
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
}


extension MailHomeController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mailHomeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch mailHomeSections[section] {
        case .writeMail:
            return 1
        case .checkMailbox:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch mailHomeSections[indexPath.section] {
        case .writeMail:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WriteMailCell.identifier, for: indexPath) as! WriteMailCell
            cell.delegate = self
            return cell
        case .checkMailbox:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckMailboxCell.identifier, for: indexPath) as! CheckMailboxCell
            cell.delegate = self
            return cell
        }
    }
}


extension MailHomeController {
    private func makeFlowLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, ev -> NSCollectionLayoutSection? in
            // section에 따라 서로 다른 layout 구성
            switch self.mailHomeSections[section] {
            case .writeMail:
                return self.makeWriteMailSectionLayout()
            case .checkMailbox:
                return self.makeCheckMailboxSectionLayout()
            }
        }
    }
    
    // '편지 작성하기' 섹션 레이아웃 생성
    private func makeWriteMailSectionLayout() -> NSCollectionLayoutSection? {
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
    
    // '편지함 확인하기' 섹션 레이아웃 생성
    private func makeCheckMailboxSectionLayout() -> NSCollectionLayoutSection? {
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
        
        // collection-view last cell bottom inset
        var collectionViewBottomInset: CGFloat
        let tabHeight = AppConst.shared.tabHeight
        
        if let safeAreaBottomInset = AppConst.shared.safeAreaInset?.bottom {
            collectionViewBottomInset = (safeAreaBottomInset + tabHeight - 20) - 16
        } else {
            collectionViewBottomInset = tabHeight - 16
        }
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        // section.orthogonalScrollingBehavior = .continuous // Horizontal scrolling
        section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                        leading: 0,
                                                        bottom: collectionViewBottomInset,
                                                        trailing: 0)
        
        return section
    }
}


extension MailHomeController: WriteMailCellDelegate {
    func writeMailButtonDidTap() {
        reactor?.action.onNext(.showMailWritingController)
    }
}


extension MailHomeController: CheckMailboxCellDelegate {
    func checkMailboxButtonDidTap() {
        reactor?.action.onNext(.showMailListController)
    }
}


extension MailHomeController: TopNavigationDelegate {
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
