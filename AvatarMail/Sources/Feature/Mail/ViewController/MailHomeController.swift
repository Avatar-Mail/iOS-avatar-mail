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
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }

    private lazy var  contentsCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout()).then {
            $0.register(WriteMailCell.self, forCellWithReuseIdentifier: WriteMailCell.identifier)
            $0.register(RectangleCell2.self, forCellWithReuseIdentifier: RectangleCell2.identifier)
        }
        return collectionView
    }()
    
    private var mailHomeSections: [MailHomeSection] = [
        MailHomeSection.writeMail,
        MailHomeSection.checkReceivedMail
    ]
    
    private let mailboxImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let checkMailButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xADABAB)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("메일함 확인하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    private let writeMailButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("메일 작성하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
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
        
        makeUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor?.action.onNext(.checkRepliedMailExists)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradientBackground(colors: [UIColor(hex: 0xFFFFFF), UIColor(hex: 0xCCCCCC)])
        
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
    }
    
    private func makeUI() {
        view.addSubViews(
            topNavigation,
            contentsCollectionView,
            mailboxImageView,
            checkMailButton,
            writeMailButton
        )
    
        // topNavigation
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        var collectionViewBottomInset: CGFloat
        let tabHeight = AppConst.shared.tabHeight
        
        if let safeAreaBottomInset = AppConst.shared.safeAreaInset?.bottom {
            collectionViewBottomInset = safeAreaBottomInset + tabHeight - 20 - 16
        } else {
            collectionViewBottomInset = tabHeight - 16
        }
        
        // collection-view
        contentsCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(collectionViewBottomInset)
        }
    }
    
    
    func bind(reactor: MailHomeReactor) {
        checkMailButton.rx.tap
            .filter { [weak self] in
                guard let self else { return false }
                return self.reactor?.currentState.repliedMailExists == true
            }
            .map { Reactor.Action.showRepliedMailController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeMailButton.rx.tap
            .map { Reactor.Action.showMailWritingController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.repliedMailExists)
            .distinctUntilChanged()
            .filter { $0 }
            .bind { [weak self] _ in
                guard let self else { return }
                self.checkMailButton.backgroundColor = UIColor(hex: 0xF8554A)
            }.disposed(by: disposeBag)
    }
    
    
    private func setupCollectionView() {
        self.contentsCollectionView.dataSource = self
        // self.contentsCollectionView.delegate = self
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
        case .checkReceivedMail:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch mailHomeSections[indexPath.section] {
        case .writeMail:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WriteMailCell.identifier, for: indexPath) as! WriteMailCell
            cell.delegate = self
            return cell
        case .checkReceivedMail:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RectangleCell2.identifier, for: indexPath) as! RectangleCell2
            cell.setData(text: "Section2")
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
            case .checkReceivedMail:
                return self.makeCheckReceivedMailSectionLayout()
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
    private func makeCheckReceivedMailSectionLayout() -> NSCollectionLayoutSection? {
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
                                                        bottom: 32,
                                                        trailing: 0)
        
        return section
    }
}


extension MailHomeController: WriteMailCellDelegate {
    func writeMailButtonDidTap() {
        reactor?.action.onNext(.showMailWritingController)
    }
}

final class RectangleCell2: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    static let identifier = "RectangleCell2"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        self.contentView.backgroundColor = .systemGreen
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(600)
        }
    }
    
    func setData(text: String) {
        label.text = text
    }
}
