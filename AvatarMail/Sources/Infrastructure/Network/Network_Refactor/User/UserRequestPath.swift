//
//  UserInfoRequestPath.swift
//  AvatarMail
//
//  Created by 최지석 on 8/17/24.
//

public enum UserRequestPath: RequestPathProtocol {
    case sendApnsToken
    
    public var rawValue: String {
        switch self {
        case .sendApnsToken:
            return "/api/user/register"
        }
    }
}

