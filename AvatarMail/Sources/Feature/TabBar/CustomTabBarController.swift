//
//  CustomTabBarController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//


import UIKit
import RxSwift
import SnapKit
import Then


class CustomTabBarController: UITabBarController {
    
    private let customTabBar = CustomTabBar()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 탭바 아이템 설정
        let tabItems: [CustomTabItem] = makeTabItems()
        
        // 탭별 뷰 컨트롤러 생성
        let navigationControllers = makeTabControllers(tabItems: tabItems)
        
        // 탭바의 뷰 컨트롤러지정
        setViewControllers(navigationControllers, animated: false)
        
        // .mail 페이지를 초기 페이지로 지정
        selectedIndex = CustomTabItem.mail.tabIndex()
        
        makeUI()
        bindUI()
    }
    
    private func makeUI() {
        // 디폴트 탭바는 숨김처리
        tabBar.isHidden = true
        
        view.addSubview(customTabBar)
        
        customTabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview()
            
            // bottom safeAreaInset 존재 여부에 따라 탭바 높이를 다르게 설정
            if let bottomSafeAreaInset = AppConst.shared.safeAreaInset?.bottom, bottomSafeAreaInset != 0 {
                $0.height.equalTo(AppConst.shared.tabHeight + bottomSafeAreaInset - 20)
            } else {
                $0.height.equalTo(AppConst.shared.tabHeight)
            }
        }
    }
    
    
    private func bindUI() {
        customTabBar.tappedItem
            .bind { [weak self] in
                guard let self else { return }
                self.selectedIndex = $0
            }
            .disposed(by: disposeBag)
    }
    
    
    private func makeTabItems() -> [CustomTabItem] {
        return CustomTabItem.allCases.sorted(by: { $0.tabIndex() < $1.tabIndex() })
    }
    
    
    private func makeTabControllers(tabItems: [CustomTabItem]) -> [UINavigationController] {
        let navigationControllers: [UINavigationController] = tabItems.map { item in
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
        
        return navigationControllers
    }
}


// MARK: - Swipe Back 제스처 처리
extension CustomTabBarController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
