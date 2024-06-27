//
//  AppConst.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import Foundation
import UIKit

public struct AppConst {
    static let shared = AppConst()
    
    private init() {}
    
    // 탭바
    let tabHeight: CGFloat = 80
    let safeAreaInset: UIEdgeInsets? = (UIApplication.shared.connectedScenes.first
        .flatMap { ($0 as? UIWindowScene)?.windows.first }?
        .flatMap { $0.safeAreaInsets })
    // 상단 탑 내비게이션
    let topNavigationHeight: CGFloat = 54
}
