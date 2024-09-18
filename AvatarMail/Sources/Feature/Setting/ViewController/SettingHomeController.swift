import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class SettingHomeController: UIViewController, View {

    var disposeBag = DisposeBag()
    
    private let topNavigation = TopNavigation().then {
        $0.setLeftLogoIcon(logoName: "white_logo_img", logoSize: CGSize(width: 25, height: 25))
        $0.setRightSidePrimaryIcon(iconName: "bell.fill", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTitle(titleText: "설정", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let collectionView: UICollectionView = {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = true // divider 설정
        listConfig.backgroundColor = .white
        listConfig.separatorConfiguration = .init(listAppearance: .plain)

        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: listConfig)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
            $0.backgroundColor = .white
            $0.register(SettingHomeCollectionViewCell.self, forCellWithReuseIdentifier: SettingHomeCollectionViewCell.identifier)
        }
        
        return collectionView
    }()
    
    init(reactor: SettingHomeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
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
            collectionView
        )
        
        // topNavigation
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        // collectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: SettingHomeReactor) {
        reactor.state
            .map { $0.settingHomeItems }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items(cellIdentifier: SettingHomeCollectionViewCell.identifier,
                                              cellType: SettingHomeCollectionViewCell.self)) { index, item, cell in
                cell.setData(item: item,
                             title: item.title,
                             subTitle: item.subTitle,
                             showArrowIcon: item.showArrowIcon)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
}

extension SettingHomeController: SettingHomeCollectionViewCellDelegate {
    
    func SettingHomeCollectionViewCellDidTap(item: SettingHomeItem) {
        switch item.id {
        case .appVersion:
            break
        case .debugMode:
            print("DebugMode clicked")
        }
    }
}

