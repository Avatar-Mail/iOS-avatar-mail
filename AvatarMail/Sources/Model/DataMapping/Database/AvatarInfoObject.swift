//
//  AvatarInfoObject.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import RealmSwift

class AvatarInfoObject: Object {
    typealias Identifier = String
    
    @Persisted(primaryKey: true) var name: Identifier  // 아바타 이름
    @Persisted var ageGroup: String?                   // 아바타 나이대
    @Persisted var avatarRole: String?                 // 아바타의 역할(관계)
    @Persisted var userRole: String?                   // 나의 역할(관계)
    @Persisted var characteristic: String?             // 아바타 성격
    @Persisted var parlance: String?                   // 아바타 말투
    
    convenience init(avatar: AvatarInfo) {
        self.init()
        
        self.name = avatar.name
        self.ageGroup = avatar.ageGroup
        self.avatarRole = avatar.relationship.avatar
        self.userRole = avatar.relationship.user
        self.characteristic = avatar.characteristic
        self.parlance = avatar.parlance
    }
}

extension AvatarInfoObject {
    // AvatarInfoObject를 AvatarInfo 엔티티로 변환
    func toEntity() -> AvatarInfo {
        return AvatarInfo(
            name: name,
            ageGroup: ageGroup,
            relationship: Relationship(avatar: avatarRole,
                                       user: userRole),
            characteristic: characteristic,
            parlance: parlance
        )
    }
}


