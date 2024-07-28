//
//  AvatarSettingItem.swift
//  AvatarMail
//
//  Created by 최지석 on 7/18/24.
//

enum AvatarSettingItem: Hashable {
    case avatarNameInput(String)
    case avatarAgeInput(String?)
    case avatarRelationshipInput(String?, String?)
    case avatarCharacteristicInput(String?)
    case avatarParlanceInput(String?)
}
