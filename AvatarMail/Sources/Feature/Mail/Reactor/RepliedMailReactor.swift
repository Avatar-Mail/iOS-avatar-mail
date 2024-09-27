//
//  RepliedMailReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class RepliedMailReactor: Reactor {
    
    enum Action {
        case closeRepliedMailController
        case replyButtonDidTap
        case startNarration
        case stopNarration
        case requestNarrationAudioFile(mailID: String)
        case deleteMail
    }
    
    enum Mutation {
        case setIsNarrating(isNarrating: Bool)
        case setNarrationAudioURL(audioURL: URL)
        case setIsMailDeleted(isDeleted: Bool)
        case setToastMessage(text: String)
    }
    
    struct State {
        var writtenMail: Mail?
        var isNarrating: Bool
        var narrationAudioURL: URL?
        
        var isMailDeleted: Bool
        
        @Pulse var toastMessage: String?
    }
    
    var initialState: State
    
    
    // MARK: - Initialization
    var coordinator: RepliedMailCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    var audioPlayingManager: AudioPlayingManager
    var ttsAdapter: TTSAdapterProtocol
    var database: RealmDatabaseProtocol

    
    init(
        coordinator: RepliedMailCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol,
        audioPlayingManager: AudioPlayingManager,
        ttsAdapter: TTSAdapterProtocol,
        database: RealmDatabaseProtocol,
        mail: Mail
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
        self.audioPlayingManager = audioPlayingManager
        self.ttsAdapter = ttsAdapter
        self.database = database
        self.initialState = State(writtenMail: mail,
                                  isNarrating: false,
                                  narrationAudioURL: nil,
                                  isMailDeleted: false,
                                  toastMessage: nil)
        
        audioPlayingManager.delegate = self
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // Logic
        case .startNarration:
            return startNarration(with: currentState.narrationAudioURL)
        case .stopNarration:
            return stopNarration()
        case .requestNarrationAudioFile(let mailID):
            return requestNarrationAudioFile(mailID: mailID)
        case .deleteMail:
            return deleteMail()
            // Navigation
        case .replyButtonDidTap:
            coordinator.showMailWritingControllerAfterClose()
            return .empty()
        case .closeRepliedMailController:
            coordinator.closeRepliedMailController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIsNarrating(isNarrating: isNarrating):
            newState.isNarrating = isNarrating
        case let .setNarrationAudioURL(audioURL: audioURL):
            newState.narrationAudioURL = audioURL
        case let .setIsMailDeleted(isDeleted: isDeleted):
            newState.isMailDeleted = isDeleted
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    
    func startNarration(with audioURL: URL?) -> Observable<Mutation> {
        if let audioURL {
            let result = audioPlayingManager.startPlaying(url: audioURL)
            
            switch result {
            case .success(_):
                return Observable.just(.setIsNarrating(isNarrating: true))
            case .failure(_):
                return Observable.of(
                    .setToastMessage(text: "파일을 재생하는데 실패했습니다."),
                    .setIsNarrating(isNarrating: false)
                )
            }
        } else {
            return Observable.of(
                .setToastMessage(text: "존재하지 않는 음성 파일입니다."),
                .setIsNarrating(isNarrating: false)
            )
        }
    }
    
    
    func stopNarration() -> Observable<Mutation> {
        
        if currentState.isNarrating {
            let result = audioPlayingManager.stopPlaying()
            
            switch result {
            case .success:
                return Observable.of(
                    .setIsNarrating(isNarrating: false)
                )
            case .failure(_):
                return Observable.of(
                    .setIsNarrating(isNarrating: false),
                    .setToastMessage(text: "파일을 재생하는 데 실패했습니다.")
                )
            }
        } else {
            return Observable.of(
                .setIsNarrating(isNarrating: false),
                .setToastMessage(text: "현재 재생 중이 아닙니다.")
            )
        }
        
    }
    
    
    private func deleteMail() -> Observable<Mutation> {
        guard let writtenMail = currentState.writtenMail else { return .empty() }
        let mailObject = MailObject(mail: writtenMail)
        
        return database.removeMail(mailObject)
            .flatMap {
                return Observable.of(
                    Mutation.setToastMessage(text: "편지가 성공적으로 삭제되었습니다."),
                    Mutation.setIsMailDeleted(isDeleted: true)
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
    
    
    private func requestNarrationAudioFile(mailID: String) -> Observable<Mutation> {
        return ttsAdapter.getNarrationAudioFile(mailID: mailID)
            .flatMap { response in
                
                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let directoryURL = documentPath.appendingPathComponent("saved_audio", isDirectory: true)
                let fileName = "\(mailID).wav"
                let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
                
                // 디렉토리가 존재하지 않으면 생성
                do {
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("[ERROR] 디렉토리 생성 실패: \(error.localizedDescription)")
                    return Observable.of(Mutation.setToastMessage(text: "다운로드 디렉터리 생성에 실패했습니다."))
                }
                
                if response.isSuccess == true, let data = response.data {
                    do {
                        try data.write(to: fileURL)
                        print("[DOWNLOAD SUCCESS] \(fileURL) 파일이 저장되었습니다.")
                        
                        return Observable.just(Mutation.setNarrationAudioURL(audioURL: fileURL))
                    } catch {
                        return Observable.of(.setToastMessage(text: "음성 파일을 저장하는 데 실패했습니다."))
                    }
                } else {
                    print("[DOWNLOAD FAIL] 파일이 존재하지 않습니다.")
                    return .empty()
                }
            }
            .catch { error in
//                let networkError = RefactoredNetworkServiceError(error: error)
//                return Observable.of(
//                    Mutation.setToastMessage(text: networkError.message ?? "서버에 편지를 보내는 과정에서 문제가 발생했습니다.")
//                )
                return .empty()  // 서버에서 해당 편지를 보낸 아바타의 음성 파일 존재 여부를 반환하지 않기 때문에, 에러 토스트 별도 노출 X
            }
    }
}


extension RepliedMailReactor: AudioPlayingManagerDelegate {
    func didFinishPlaying(with fileURL: String?) {
        action.onNext(.stopNarration)
    }
}
