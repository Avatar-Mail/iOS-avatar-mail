//
//  Notification.swift
//  AvatarMail
//
//  Created by 최지석 on 10/3/24.
//

import Foundation

extension Notification.Name {
    // 신규 편지(푸시 알림)가 도착한 경우
    static let replyMailReceived = Notification.Name("ReplyMailReceived")
    // 신규 편지(푸시 알림)가 사용자에 의해 확인된 경우
    static let replyMailChecked = Notification.Name("ReplyMailChecked")
}
