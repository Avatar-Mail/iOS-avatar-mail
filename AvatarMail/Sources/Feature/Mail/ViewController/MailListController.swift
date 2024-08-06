//
//  MailListController.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import UIKit
import ReactorKit
import Then
import RxCocoa
import RxSwift
import RxGesture

class MailListController: UIViewController, View {

    typealias Reactor = MailListReactor

    var disposeBag = DisposeBag()

    private let topNavigation = TopNavigation().then {
        $0.setTitle(titleText: "나의 편지함", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    // 필터 확장 버튼
    private let filterExtendButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("필터")
        title.font = UIFont.content(size: 16, weight: .regular)
        title.foregroundColor = UIColor(hex: 0x7B7B7B)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "slider.horizontal.3", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 3
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0x7B7B7B)
    }

    private let filterContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.applyBorder(to: .bottom, width: 1, color: UIColor(hex:0xCECECE))
    }

    private let mailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 16 + 54, left: 0, bottom: 16, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RepliedMailCell.self, forCellWithReuseIdentifier: RepliedMailCell.identifier)
        collectionView.backgroundColor = UIColor(hex: 0xEFEFEF)
        return collectionView
    }()

    init(reactor: MailListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        topNavigation.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.getAllMails)
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
    }

    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            
            topNavigation,
            
            filterContainerView.addSubViews(
                filterExtendButton
            ),
            
            mailCollectionView
        )

        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        filterContainerView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        filterExtendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }

        mailCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }

        view.bringSubviewToFront(filterContainerView)
    }

    func bind(reactor: MailListReactor) {
        filterExtendButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                // TODO: 필터 버튼 추가
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.filteredMails }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: mailCollectionView.rx.items(cellIdentifier: RepliedMailCell.identifier,
                                                  cellType: RepliedMailCell.self)) { index, mail, cell in
                cell.setData(mail: mail)
                cell.delegate = self
            }
            .disposed(by: disposeBag)

        
        reactor.pulse(\.$toastMessage)
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
    }
}

extension MailListController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeMailListController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {}
    
    func topNavigationRightSideSecondaryIconDidTap() {}
    
    func topNavigationRightSideTextButtonDidTap() {}
}


extension MailListController: RepliedMailCellDelegate {
    func repliedMailCellDidTap(mail: Mail) {
        reactor?.action.onNext(.showRepliedMailController(mail: mail))
    }
}
