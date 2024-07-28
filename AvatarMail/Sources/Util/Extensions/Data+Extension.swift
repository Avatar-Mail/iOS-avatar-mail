//
//  Data+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
