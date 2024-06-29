//
//  TabBarController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit

@available(*, deprecated, renamed: "CustomTabBarController", message: "CustomTabBarController로 탭바 컴포넌트 변경")
class TabBarController: UITabBarController {
    
    deinit {
        debugPrint("TabBarController deinit")
    }
    
    override func viewDidLoad() {
        // (1) 탭바 아이템 리스트 생성
        let pages: [TabBarPage] = TabBarPage.allCases.sorted(by: { $0.pageIndex() < $1.pageIndex() })
        
        // (2) 탭바 아이템 생성
        let tabBarItems: [UITabBarItem] = pages.map { self.createTabBarItem(of: $0)}
        
        // (3) 탭바별 내비게이션 컨트롤러 생성
        let navigationControllers: [UINavigationController] = tabBarItems.map {
            self.createTabNavigationController(tabBarItem: $0)
        }
        
        // (4) 탭바별 코디네이터 생성
        navigationControllers.forEach {
            self.startTabCoordinator(tabNavigationController: $0)
        }
        
        // (5) 탭바 스타일 지정 및 뷰 컨트롤러 연결
        configureTabBarController(tabNavigationControllers: navigationControllers)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 탭 바 높이 변경
        setTabBarHeight()
    }
    
    
    // MARK:  주어진 페이지를 현재 페이지로 설정하는 메서드
    func selectPage(_ page: TabBarPage) {
        selectedIndex = page.pageIndex()
    }
    
    
    // MARK: 주어진 인덱스를 갖는 페이지를 현재 페이지로 설정하는 메서드
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        selectedIndex = page.pageIndex()
    }
    
    
    // MARK: 현재 페이지를 반환하는 메서드
    func currentPage() -> TabBarPage? {
        TabBarPage.init(index: selectedIndex)
    }
    
    
    //MARK: 탭바 아이템 생성 메서드
    private func createTabBarItem(of page: TabBarPage) -> UITabBarItem {
        return UITabBarItem(
            title: page.pageName(),
            image: UIImage(systemName: page.iconName()),
            tag: page.pageIndex()
        )
    }
    
    
    // MARK: 탭별 네비게이션 컨트롤러 생성 메서드
    private func createTabNavigationController(tabBarItem: UITabBarItem) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        
        // 뒤로가기 모션 제스쳐 설정 (Enable)
        tabNavigationController.interactivePopGestureRecognizer?.delegate = self
        
        tabNavigationController.isNavigationBarHidden = true
        tabNavigationController.tabBarItem = tabBarItem
        
        return tabNavigationController
    }
    
    
    // MARK: 탭별 코디네이터 생성 메서드
    private func startTabCoordinator(tabNavigationController: UINavigationController) {
        let tabBarPageTag: Int = tabNavigationController.tabBarItem.tag
        guard let tabBarPage: TabBarPage = TabBarPage(index: tabBarPageTag) else { return }
        
        // 코디네이터 생성 및 실행
        switch tabBarPage {
        case .mail:
            let mailHomeCoordinator = MailHomeCoordinator(navigationController: tabNavigationController)
            mailHomeCoordinator.start()
        case .avatar:
            let avatarHomeCoordinator = AvatarHomeCoordinator(navigationController: tabNavigationController)
            avatarHomeCoordinator.start()
        }
    }
    
    
    // MARK: 탭바 스타일 지정 및 초기화 메서드
    private func configureTabBarController(tabNavigationControllers: [UINavigationController]) {
        // TabBar의 ViewControllers 지정
        setViewControllers(tabNavigationControllers, animated: false)
        
        // .mail 페이지를 초기 페이지로 지정
        selectedIndex = TabBarPage.mail.pageIndex()
        
        // 탭바 아이콘 및 바탕색 변경
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.tintColor = UIColor(hex: 0xF8554A)
        tabBar.backgroundColor = .white
        
        // 탭바 둥근 테두리 설정
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.layer.cornerRadius = 30
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    
    // MARK: 탭바 높이 설정 메서드
    private func setTabBarHeight() {
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = 90
        tabBarFrame.origin.y = view.frame.size.height - 90
        tabBar.frame = tabBarFrame
    }
}

// MARK: - Swipe Back 제스처 처리
extension TabBarController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

