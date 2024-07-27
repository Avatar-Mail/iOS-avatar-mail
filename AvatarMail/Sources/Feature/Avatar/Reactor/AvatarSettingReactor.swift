//
//  AvatarSettingReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class AvatarSettingReactor: Reactor {

    enum Action {
        // Logic
        case avatarNameDidChange(name: String)
        case avatarAgeDidChange(age: String?)
        case avatarSelfRoleDidChange(avatarRole: String?)
        case avatarUserRoleDidChange(userRole: String?)
        case avatarCharacteristicDidChange(characteristic: String?)
        case avatarParlanceDidChange(parlance: String?)
        case saveAvatar
        case startRecording(recordingContents: String?)
        case stopRecording
        case startPlaying(recording: AudioRecording)
        case stopPlaying
        // Navigation
        case closeAvatarSettingController
    }
    
    enum Mutation {
        case setAvatarName(name: String)
        case setAvatarAge(age: String?)
        case setAvatarSelfRole(avatarRole: String?)
        case setAvatarUserRole(userRole: String?)
        case setAvatarCharacteristic(characteristic: String?)
        case setAvatarParlance(parlance: String?)
        case setIsRecording(isRecording: Bool)
        case setIsPlaying(isPlaying: Bool)
        case addRecording(recording: AudioRecording)
        case setAvatarHasSaved(hasSaved: Bool)
        case setToastMessage(text: String)
    }
    
    struct State {
        var name: String                    // 이름
        var age: String?                    // 나이
        var avatarRole: String?             // 아바타의 역할(관계)
        var userRole: String?               // 사용자의 역할(관계)
        var characteristic: String?         // 성격
        var parlance: String?               // 말투
        var recordings: [AudioRecording]    // 음성 녹음 파일들
        
        var isRecording: Bool               // 녹음 중인지 여부
        var isPlaying: Bool                 // 재생 중인지 여부
        
        var hasAvatarSaved: Bool            // 아바타 저장 여부
        
        @Pulse var toastMessage: String?
    }
    
    var initialState: State
    
    
    // MARK: - Initialization
    var coordinator: AvatarSettingCoordinator
    var database: RealmDatabaseProtocol
    var audioRecordingManager: AudioRecordingManager
    var audioPlayingManager: AudioPlayingManager
    
    init(
        coordinator: AvatarSettingCoordinator,
        database: RealmDatabaseProtocol,
        audioRecordingManager: AudioRecordingManager,
        audioPlayingManager: AudioPlayingManager,
        avatar: AvatarInfo?
    ) {
        self.coordinator = coordinator
        self.database = database
        self.audioRecordingManager = audioRecordingManager
        self.audioPlayingManager = audioPlayingManager

        self.initialState = State(name: avatar?.name ?? "",
                                  age: avatar?.ageGroup,
                                  avatarRole: avatar?.relationship.avatar,
                                  userRole: avatar?.relationship.user,
                                  characteristic: avatar?.characteristic,
                                  parlance: avatar?.parlance, 
                                  recordings: avatar?.recordings ?? [],
                                  isRecording: false,
                                  isPlaying: false,
                                  hasAvatarSaved: false)
        
        self.audioPlayingManager.delegate = self
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case let .avatarNameDidChange(name: name):
            return Observable.just(Mutation.setAvatarName(name: name))
        case let .avatarAgeDidChange(age: age):
            return Observable.just(Mutation.setAvatarAge(age: age))
        case let .avatarSelfRoleDidChange(avatarRole: avatarRole):
            return Observable.just(Mutation.setAvatarSelfRole(avatarRole: avatarRole))
        case let .avatarUserRoleDidChange(userRole: userRole):
            return Observable.just(Mutation.setAvatarUserRole(userRole: userRole))
        case let .avatarCharacteristicDidChange(characteristic: characteristic):
            return Observable.just(Mutation.setAvatarCharacteristic(characteristic: characteristic))
        case let .avatarParlanceDidChange(parlance: parlance):
            return Observable.just(Mutation.setAvatarParlance(parlance: parlance))
        case let .startRecording(recordingContents: recordingContents):
            return startRecording(recordingContents: recordingContents)
        case .stopRecording:
            return stopRecording()
        case let .startPlaying(recording: recording):
            return startPlaying(recording: recording)
        case .stopPlaying:
            return stopPlaying()
        case .saveAvatar:
            let avatar = AvatarInfo(name: currentState.name,
                                    ageGroup: currentState.age,
                                    relationship: Relationship(avatar: currentState.avatarRole,
                                                               user: currentState.userRole),
                                    characteristic: currentState.characteristic,
                                    parlance: currentState.parlance,
                                    recordings: currentState.recordings)
            return saveAvatar(avatar)
            
        // Navigation
        case .closeAvatarSettingController:
            coordinator.closeAvatarSettingController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setAvatarName(name: name):
            newState.name = name
        case let .setAvatarAge(age: age):
            newState.age = age
        case let .setAvatarSelfRole(avatarRole: avatarRole):
            newState.avatarRole = avatarRole
        case let .setAvatarUserRole(userRole: userRole):
            newState.userRole = userRole
        case let .setAvatarCharacteristic(characteristic: characteristic):
            newState.characteristic = characteristic
        case let .setAvatarParlance(parlance: parlance):
            newState.parlance = parlance
        case let .setIsRecording(isRecording: isRecording):
            newState.isRecording = isRecording
        case let .addRecording(recording: recording):
            newState.recordings = state.recordings + [recording]
        case let .setIsPlaying(isPlaying: isPlaying):
            newState.isPlaying = isPlaying
        case let .setAvatarHasSaved(hasSaved: hasSaved):
            newState.hasAvatarSaved = hasSaved
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    
    private func saveAvatar(_ avatar: AvatarInfo) -> Observable<Mutation> {
        
        guard avatar.name.isNotEmpty else {
            return Observable.just(.setToastMessage(text: "아바타 이름을 입력하세요."))
        }
        
        let avatarObject = AvatarInfoObject(avatar: avatar)
        
        return database.saveAvatar(avatarObject)
            .flatMap { toastMessage in
                return Observable.of(
                    Mutation.setToastMessage(text: toastMessage),
                    Mutation.setAvatarHasSaved(hasSaved: true)
                )
            }
            .catch { error in
                if let error = error as? RealmDatabaseError {
                    switch error {
                    case .RealmDatabaseNotInitializedError(let message):
                        return Observable.just(Mutation.setToastMessage(text: message ?? "RealmDatabaseNotInitializedError"))
                    case .RealmDatabaseError(let message):
                        return Observable.just(Mutation.setToastMessage(text: message ?? "RealmDatabaseError"))
                    }
                } else {
                    return Observable.just(Mutation.setToastMessage(text: "Unknown RealmDatabaseError"))
                }
            }
    }
    
    private func startRecording(recordingContents: String?) -> Observable<Mutation> {
        
        if let recordingContents, !recordingContents.isEmpty {
            let result = audioRecordingManager.startRecording(contents: recordingContents,
                                                              with: currentState.name)
            
            switch result {
            case .success(_):
                return Observable.just(.setIsRecording(isRecording: true))
            case .failure(_):
                return Observable.just(.setToastMessage(text: "녹음하는데 실패했습니다."))
            }
        } else {
            return Observable.just(.setToastMessage(text: "녹음할 문장을 먼저 입력해주세요."))
        }
    }
    
    private func stopRecording() -> Observable<Mutation> {
        
        if currentState.isRecording {
            let result = audioRecordingManager.stopRecording()
            
            switch result {
            case .success(let recording):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .addRecording(recording: recording),
                    .setToastMessage(text: "정상적으로 녹음을 완료했습니다.")
                )
            case .failure(_):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .setToastMessage(text: "녹음하는 데 실패했습니다.")
                )
            }
        } else {
            return Observable.of(
                .setIsRecording(isRecording: false),
                .setToastMessage(text: "현재 녹음 중이 아닙니다.")
            )
        }
    }
    
    private func startPlaying(recording: AudioRecording) -> Observable<Mutation> {
        
        let result = audioPlayingManager.startPlaying(url: recording.fileURL)
            
        switch result {
        case .success(_):
            return Observable.just(.setIsPlaying(isPlaying: true))
        case .failure(_):
            return Observable.just(.setToastMessage(text: "파일을 재생하는데 실패했습니다."))
        }
    }
    
    private func stopPlaying() -> Observable<Mutation> {
        
        if currentState.isPlaying {
            let result = audioPlayingManager.stopPlaying()
            
            switch result {
            case .success:
                return Observable.of(
                    .setIsPlaying(isPlaying: false)
                )
            case .failure(_):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .setToastMessage(text: "재생하는 데 실패했습니다.")
                )
            }
        } else {
            return Observable.of(
                .setIsRecording(isRecording: false),
                .setToastMessage(text: "현재 재생 중이 아닙니다.")
            )
        }
    }
}



extension AvatarSettingReactor: AudioPlayingManagerDelegate {
    func didFinishPlaying(with fileURL: String?) {
        print("fileURL finished")
        self.action.onNext(.stopPlaying)
    }
}
