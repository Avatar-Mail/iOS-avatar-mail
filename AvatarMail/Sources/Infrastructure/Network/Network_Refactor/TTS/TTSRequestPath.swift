//
//  TTSRequestPath.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation

public enum TTSRequestPath: RequestPathProtocol {
    case saveAvatar
    case sendMail
    case getMail(mailID: String)
    
    public var rawValue: String {
        switch self {
        case .saveAvatar:
            return "/api/tts/model"
        case .sendMail:
            return "/api/tts"
        case .getMail(let mailID):
            return "/api/tts/\(mailID)"
        }
    }
}
