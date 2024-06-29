//
//  MailWritingReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class MailWritingReactor: Reactor {
    
    enum Action {
        // Logic
        case hideToolTip
        case senderNameTextDidChange(text: String)
        case inputTextDidChange(text: String)
        case recipientNameTextDidChange(text: String)
        case sendButtonDipTap
        // Navigation
        case closeMailWritingController
    }
    
    enum Mutation {
        case setSenderNameText(text: String)
        case setInputText(text: String)
        case setRecipientNameText(text: String)
        case setIsMailSent(isSent: Bool)
        case setIsTooltipHidden(isHidden: Bool)
        case setToastMessage(text: String)
    }
    
    struct State {
        var senderNameText: String
        var inputText: String
        var recipientNameText: String
        var isMailSent: Bool
        var isTooltipHidden: Bool
        
        @Pulse var toastMessage: String
    }
    
    let initialState = State(
        senderNameText: "",
        inputText: "",
        recipientNameText: "",
        isMailSent: false,
        isTooltipHidden: false,
        
        toastMessage: ""
    )
    
    
    // MARK: - Initialization
    var coordinator: MailWritingCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    var database: RealmDatabase
    
    init(
        coordinator: MailWritingCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol,
        database: RealmDatabase
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
        self.database = database
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case let .senderNameTextDidChange(text: text):
            return Observable.just(Mutation.setSenderNameText(text: text))
        case let .inputTextDidChange(text: text):
            return Observable.just(Mutation.setInputText(text: text))
        case let .recipientNameTextDidChange(text: text):
            return Observable.just(Mutation.setRecipientNameText(text: text))
        case .sendButtonDipTap:
            return sendMail(senderName: currentState.senderNameText,
                            content: currentState.inputText,
                            recipientName: currentState.recipientNameText)
        case .hideToolTip:
            return Observable.just(Mutation.setIsTooltipHidden(isHidden: true))
        // Navigation
        case .closeMailWritingController:
            coordinator.closeMailWritingController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSenderNameText(text: text):
            newState.senderNameText = text
        case let .setInputText(text: text):
            newState.inputText = text
        case  let .setRecipientNameText(text: text):
            newState.recipientNameText = text
        case let .setIsMailSent(isSent: isSent):
            newState.isMailSent = isSent
        case let .setIsTooltipHidden(isHidden: isHidden):
            newState.isTooltipHidden = isHidden
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    
    private func sendMail(senderName: String,
                          content: String,
                          recipientName: String) -> Observable<Mutation> {
        
        // 발신인 이름이 없는 경우
        if senderName.isEmpty {
            return Observable.just(.setToastMessage(text: "메일을 작성하는 사람의 이름을 입력하세요."))
        }
        // 수신인 이름이 없는 경우
        else if recipientName.isEmpty {
            return Observable.just(.setToastMessage(text: "메일을 받는 사람의 이름을 입력하세요."))
        }
        // 메일의 내용이 없는 경우
        else if content.isEmpty {
            return Observable.just(.setToastMessage(text: "메일의 내용을 입력하세요."))
        }
        
        let avatarName = recipientName  // 수신인 이름 -> 아바타 이름
    
        // 주어진 recipientName으로, 해당 이름을 갖는 아바타가 있으면 해당 아바타를 가져와서 AvatarInfo를 세팅한다.
        return database.getAvatar(withName: avatarName)
            .flatMap { [weak self] avatarInfoObject -> Observable<Mutation> in
                guard let self else { return .empty() }
                
                let avatarInfo = avatarInfoObject?.toEntity()
                
                return openAIService.sendMail(senderName: senderName,
                                              content: content,
                                              recipientName: recipientName,
                                              avatarInfo: avatarInfo)
                    .flatMap { text in
                        Observable.of(
                            Mutation.setIsMailSent(isSent: true),
                            Mutation.setToastMessage(text: text)
                        )
                    }
                    .catch { error in
                        print(error.localizedDescription)
                        return Observable.just(.setToastMessage(text: "메일을 보내는 과정에서 문제가 발생했습니다."))
                    }
            }
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(.setToastMessage(text: "아바타 정보를 불러오는 과정에서 문제가 발생했습니다."))
            }
    }
}

