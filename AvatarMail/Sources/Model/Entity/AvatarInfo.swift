//
//  AvatarInfo.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation

struct AvatarInfo: Hashable {
    typealias Identifier = String
    
    let name: Identifier            // 이름
    let ageGroup: String?           // 나이대
    let relationship: Relationship  // 관계
    let characteristic: String?     // 성격
    let parlance: String?           // 말투
}


struct Relationship: Hashable {
    let avatar: String?
    let user: String?
}
