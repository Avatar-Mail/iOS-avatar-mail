//
//  TabBarPage.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation

@available(*, deprecated, renamed: "CustomTabItem", message: "CustomTabItem로 탭바 내 아이템 변경")
enum TabBarPage: String, CaseIterable {
    case mail, avatar
    
    // Int형에 맞춰 초기화
    init?(index: Int) {
        switch index {
        case 0: self = .mail
        case 1: self = .avatar
        default: return nil
        }
    }
    
    /// TabBarPage 형을 매칭되는 Int형으로 반환
    func pageIndex() -> Int {
        switch self {
        case .mail: return 0
        case .avatar: return 1
        }
    }
    
    /// TabBarPage 형을 매칭되는 한글명으로 변환
    func pageName() -> String {
        switch self {
        case .mail: return "메일함"
        case .avatar: return "아바타 설정"
        }
    }
    
    /// TabBarPage 형을 매칭되는 아이콘명으로 변환
    func iconName() -> String {
        switch self {
        case .mail: return "mail.fill"
        case .avatar: return "person.crop.square"
        }
    }
}

