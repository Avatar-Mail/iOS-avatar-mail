//
//  CustomTabBarController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//


import UIKit
import RxSwift
import SnapKit

class CustomTabBarController: UITabBarController {
    
    private let customTabBar = CustomTabBar()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        setupProperties()
        bindUI()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func makeUI() {
        view.addSubview(customTabBar)
        
        customTabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(90)
        }
    }

    
    private func setupProperties() {
        tabBar.isHidden = true
        
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.addShadow()
        
        selectedIndex = 0
        
        let items: [CustomTabItem] = CustomTabItem.allCases.sorted(by: { $0.tabIndex() < $1.tabIndex() })
        
        let navigationControllers: [UINavigationController] = items.map { item in
            let tabNavigationController = UINavigationController()
            
            // 뒤로가기 모션 제스쳐 설정 (Enable)
            tabNavigationController.interactivePopGestureRecognizer?.delegate = self
            
            tabNavigationController.isNavigationBarHidden = true
            
            switch item {
            case .mail:
                let mailHomeCoordinator = MailHomeCoordinator(navigationController: tabNavigationController)
                mailHomeCoordinator.start()
            case .avatar:
                let avatarHomeCoordinator = AvatarHomeCoordinator(navigationController: tabNavigationController)
                avatarHomeCoordinator.start()
            case .setting:
                let settingHomeCoordinator = SettingHomeCoordinator(navigationController: tabNavigationController)
                settingHomeCoordinator.start()
            }
            
            return tabNavigationController
        }
        
        // TabBar의 ViewControllers 지정
        setViewControllers(navigationControllers, animated: false)
        
        // .mail 페이지를 초기 페이지로 지정
        selectedIndex = CustomTabItem.mail.tabIndex()
    }

    
    private func selectTabWith(index: Int) {
        self.selectedIndex = index
    }
    
    
    private func bindUI() {
        customTabBar.tappedItem
            .bind { [weak self] in self?.selectTabWith(index: $0) }
            .disposed(by: disposeBag)
    }
}


// MARK: - Swipe Back 제스처 처리
extension CustomTabBarController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
