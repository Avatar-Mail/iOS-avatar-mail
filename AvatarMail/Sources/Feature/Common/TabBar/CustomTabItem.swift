//
//  CustomTabItem.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case mail
    case avatar
    case setting
}
 
extension CustomTabItem {
    func tabIndex() -> Int {
        switch self {
        case .mail: return 0
        case .avatar: return 1
        case .setting: return 2
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .mail:
            return UIImage(systemName: "envelope.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .avatar:
            return UIImage(systemName: "person.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: "gearshape.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .mail:
            return UIImage(systemName: "envelope.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .avatar:
            return UIImage(systemName: "person.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: "gearshape.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    var name: String {
        switch self {
        case .mail:
            return "편지함"
        case .avatar:
            return "아바타"
        case .setting:
            return "설정"
        }
    }
}


