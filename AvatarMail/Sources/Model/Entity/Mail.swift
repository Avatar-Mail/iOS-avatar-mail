//
//  Mail.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation

struct Mail: Equatable {
    var recipientName: String
    var content: String
    var senderName: String
    var date: Date
    var isSentFromUser: Bool
    var audioRecording: AudioRecording?
}
