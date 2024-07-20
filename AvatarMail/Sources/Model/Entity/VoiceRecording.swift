//
//  VoiceRecording.swift
//  AvatarMail
//
//  Created by 최지석 on 7/19/24.
//

import Foundation

struct VoiceRecording: Hashable {
    typealias Identifier = String
    
    let id: String                 // 파일 식별자
    let fileName: String           // 파일 이름
    let fileURL: URL               // 파일 URL
    let createdAtString: String    // 파일 생성 시간
    let recordingDuration: Double  // 음성 기록 시간
}

