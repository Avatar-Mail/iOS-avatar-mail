//
//  UITabBarController+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import UIKit

extension UITabBarController {
    func hideTabBar(isHidden: Bool, animated: Bool) {
        if let customTabBarController = self as? CustomTabBarController {
            guard customTabBarController.customTabBar.isHidden != isHidden else { return }
            let tabBar = customTabBarController.customTabBar
            let tabBarHeight = tabBar.frame.size.height
            let duration: TimeInterval = animated ? 0.3 : 0.0
            
            if isHidden {
                UIView.animate(withDuration: duration, animations: {
                    tabBar.frame.origin.y += tabBarHeight
                }, completion: { _ in
                    tabBar.isHidden = true
                })
            } else {
                tabBar.isHidden = false
                tabBar.frame.origin.y += tabBarHeight
                UIView.animate(withDuration: duration, animations: {
                    tabBar.frame.origin.y -= tabBarHeight
                })
            }
        } else {
            guard tabBar.isHidden != isHidden else { return }
            let tabBar = self.tabBar
            let tabBarHeight = tabBar.frame.size.height
            let duration: TimeInterval = animated ? 0.3 : 0.0
            
            if isHidden {
                UIView.animate(withDuration: duration, animations: {
                    tabBar.frame.origin.y += tabBarHeight
                }, completion: { _ in
                    tabBar.isHidden = true
                })
            } else {
                tabBar.isHidden = false
                tabBar.frame.origin.y += tabBarHeight
                UIView.animate(withDuration: duration, animations: {
                    tabBar.frame.origin.y -= tabBarHeight
                })
            }
        }
    }
}
