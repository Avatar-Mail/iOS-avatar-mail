//
//  AvatarInfo.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation

struct AvatarInfo: Hashable, Codable {
    typealias Identifier = String
    
    let id: Identifier                // 아바타 ID
    let name: String                  // 이름
    let ageGroup: String?             // 나이대
    let relationship: Relationship    // 관계
    let characteristic: String?       // 성격
    let parlance: String?             // 말투
    let recordings: [AudioRecording]  // 음성 파일
}


struct Relationship: Hashable, Codable {
    let avatar: String?
    let user: String?
}
