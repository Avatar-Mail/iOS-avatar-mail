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
    }
    
    enum Mutation {
        case setIsNarrating(isNarrating: Bool)
        case setToastMessage(text: String)
        case setNarrationAudioURL(audioURL: URL)
    }
    
    struct State {
        var writtenMail: Mail?
        var isNarrating: Bool
        var narrationAudioURL: URL?
        
        @Pulse var toastMessage: String?
    }
    
    var initialState: State
    
    
    // MARK: - Initialization
    var coordinator: RepliedMailCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    var audioPlayingManager: AudioPlayingManager
    var ttsAdapter: TTSAdapterProtocol

    
    init(
        coordinator: RepliedMailCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol,
        audioPlayingManager: AudioPlayingManager,
        ttsAdapter: TTSAdapterProtocol,
        mail: Mail
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
        self.audioPlayingManager = audioPlayingManager
        self.ttsAdapter = ttsAdapter
        self.initialState = State(writtenMail: mail,
                                  isNarrating: false,
                                  narrationAudioURL: nil,
                                  toastMessage: nil)
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // Logic
            
            // Navigation
        case .replyButtonDidTap:
            coordinator.showMailWritingControllerAfterClose()
            return .empty()
        case .closeRepliedMailController:
            coordinator.closeRepliedMailController()
            return .empty()
        case .startNarration:
            return startNarration(with: currentState.narrationAudioURL)
        case .stopNarration:
            return stopNarration()
        case .requestNarrationAudioFile(let mailID):
            return requestNarrationAudioFile(mailID: mailID)
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIsNarrating(isNarrating: isNarrating):
            newState.isNarrating = isNarrating
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        case let .setNarrationAudioURL(audioURL: audioURL):
            newState.narrationAudioURL = audioURL
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
    
    
    private func requestNarrationAudioFile(mailID: String) -> Observable<Mutation> {
        return ttsAdapter.getNarrationAudioFile(mailID: mailID)
            .flatMap { response in
                
                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let directoryURL = documentPath.appendingPathComponent("saved_audio", isDirectory: true)
                let fileName = "\(mailID).wav"
                let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
                
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
                let networkError = RefactoredNetworkServiceError(error: error)
                return Observable.of(
                    Mutation.setToastMessage(text: networkError.message ?? "서버에 편지를 보내는 과정에서 문제가 발생했습니다.")
                )
            }
    }
}

