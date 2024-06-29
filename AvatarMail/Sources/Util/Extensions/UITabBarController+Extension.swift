//
//  UITabBarController+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import UIKit

extension UITabBarController {
    func hideTabBar(isHidden: Bool, animated: Bool){
        if let customTabBarController = self as? CustomTabBarController {
            if customTabBarController.customTabBar.isHidden == isHidden { return }
            
            let tabBarFrame = customTabBarController.customTabBar.frame
            let offset = isHidden ? tabBarFrame.size.height: -tabBarFrame.size.height
            let duration:TimeInterval = (animated ? 0.3 : 0.0)
            
            customTabBarController.customTabBar.isHidden = false
            
            UIView.animate(withDuration: duration,
                           animations: { customTabBarController.customTabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: offset) },
                           completion: { _ in customTabBarController.customTabBar.isHidden = isHidden })
        } else {
            if tabBar.isHidden == isHidden { return }
            
            let tabBarFrame = tabBar.frame
            let offset = isHidden ? tabBarFrame.size.height: -tabBarFrame.size.height
            let duration:TimeInterval = (animated ? 0.3 : 0.0)
            
            tabBar.isHidden = false
            
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in self?.tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: offset) },
                           completion: { [weak self] _ in self?.tabBar.isHidden = isHidden })
        }
    }
}
