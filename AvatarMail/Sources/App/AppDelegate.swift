//
//  AppDelegate.swift
//  IOSAvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 의존성 초기화
        AppContainer.shared.registerDepedencies()

        window = UIWindow(frame: UIScreen.main.bounds) // 변경된 부분
        window?.rootViewController = CustomTabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
}


