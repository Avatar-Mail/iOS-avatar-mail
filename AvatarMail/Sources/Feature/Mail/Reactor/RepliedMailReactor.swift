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
        case requestNarrationAudioFile
    }
    
    enum Mutation {
        case setIsNarrating(isNarrating: Bool)
        case setToastMessage(text: String)
    }
    
    struct State {
        var writtenMail: Mail?
        var isNarrating: Bool
        
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
            return startNarration(with: currentState.writtenMail?.audioRecording)
        case .stopNarration:
            return stopNarration()
        case .requestNarrationAudioFile:
            guard let mailID = currentState.writtenMail?.id else { return .empty() }
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
        }
        
        return newState
    }
    
    
    func startNarration(with recording: AudioRecording?) -> Observable<Mutation> {
        if let recording {
            let result = audioPlayingManager.startPlaying(url: recording.fileURL)
            
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
        return self.ttsAdapter.getMail(mailID: mailID)
            .flatMap { response in
                response.
            }
            .catch { error in
                let networkError = RefactoredNetworkServiceError(error: error)
                return Observable.of(
                    Mutation.setIsMailSent(isSent: false),
                    Mutation.setToastMessage(text: networkError.message ?? "서버에 편지를 보내는 과정에서 문제가 발생했습니다.")
                )
            }
    }
}

