//
//  AudioRecordingObject.swift
//  AvatarMail
//
//  Created by 최지석 on 7/20/24.
//

import Foundation
import RealmSwift

class AudioRecordingObject: Object {
    typealias Identifier = String
    
    @Persisted var id: Identifier                     // 파일 식별자
    @Persisted var fileName: String                   // 파일 이름
    @Persisted var contents: String                   // 파일(음성 녹음) 내용
    @Persisted var createdDate: Date                  // 파일 생성 시간
    @Persisted var duration: Double                   // 녹음 시간
    @Persisted(originProperty: "recordings") var avatar: LinkingObjects<AvatarInfoObject>
    
    convenience init(recording: AudioRecording) {
        self.init()
        
        self.id = recording.id
        self.fileName = recording.fileName
        self.contents = recording.contents
        self.createdDate = recording.createdDate
        self.duration = recording.duration
    }
}

extension AudioRecordingObject {
    
    // AudioRecordingObject를 AudioRecording 엔티티로 변환
    func toEntity() -> AudioRecording {
        return AudioRecording(
            id: id,
            fileName: fileName,
            contents: contents,
            createdDate: createdDate,
            duration: duration
        )
    }
}
