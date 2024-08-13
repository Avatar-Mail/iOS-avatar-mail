//
//  MailObject.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//


import RealmSwift
import Foundation

class MailObject: Object {
    typealias Identifier = String
    
    @Persisted(primaryKey: true) var id: Identifier
    @Persisted var recipientName: String
    @Persisted var content: String
    @Persisted var senderName: String
    @Persisted var date: Date
    @Persisted var isSentFromUser: Bool

    convenience init(mail: Mail) {
        self.init()
        self.id = mail.id
        self.recipientName = mail.recipientName
        self.content = mail.content
        self.senderName = mail.senderName
        self.date = mail.date
        self.isSentFromUser = mail.isSentFromUser
    }
}

extension MailObject {
    func toEntity() -> Mail {
        return Mail(
            id: id,
            recipientName: recipientName,
            content: content,
            senderName: senderName,
            date: date,
            isSentFromUser: isSentFromUser
        )
    }
}
