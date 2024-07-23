//
//  VoiceRecording.swift
//  AvatarMail
//
//  Created by 최지석 on 7/19/24.
//

import Foundation

struct AudioRecording: Hashable {
    typealias Identifier = String
    
    let id: Identifier            // 파일 식별자
    let fileName: String          // 파일 이름 (미사용)
    let fileURL: URL              // 파일 URL
    let contents: String          // 파일(음성 녹음) 내용
    let createdDate: String       // 파일 생성 시간
    var duration: TimeInterval    // 녹음 시간
}

