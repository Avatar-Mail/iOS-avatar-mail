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
        // MARK: Logic
        case hideToolTip
        case sendButtonDipTap
        // recipient
        case recipientNameTextDidChange(text: String)
        case getAllAvatarInfos
        case clearFilteredAvatarInfos
        case changeSelectedAvatar(avatar: AvatarInfo)
        case initializeRecipientStates
        // content
        case letterContentsTextDidChange(text: String)
        case initializeLetterContentStates
        // sender
        case senderNameTextDidChange(text: String)
        case initializeSenderStates
        
        
        // MARK: Navigation
        case closeMailWritingController
        case showAvatarSettingController
    }
    
    enum Mutation {
        case setIsMailSent(isSent: Bool)
        case setIsTooltipHidden(isHidden: Bool)
        case setToastMessage(text: String)
        // recipient
        case setRecipientNameText(text: String)
        case setSelectedAvatar(avatarInfo: AvatarInfo?)
        case setFilteredAvatarInfos(avatarInfos: [AvatarInfo])
        case setAvatarInfos(avatarInfos: [AvatarInfo])
        // letter contents
        case setLetterContentsText(text: String)
        // sender
        case setSenderNameText(text: String)
    }
    
    struct State {
        var isTooltipHidden: Bool
        
        // recipient
        var recipientNameText: String
        var selectedAvatar: AvatarInfo?
        var avatarInfos: [AvatarInfo]
        var filteredAvatarInfos: [AvatarInfo]
        // letter contents
        var letterContentsText: String
        // sender
        var senderNameText: String
        
        @Pulse var isMailSent: Bool
        @Pulse var toastMessage: String?
    }
    
    let initialState = State(
        isTooltipHidden: false,
        
        recipientNameText: "",
        selectedAvatar: nil,
        avatarInfos: [],
        filteredAvatarInfos: [],
        
        letterContentsText: "",
        
        senderNameText: "",
        
        isMailSent: false,
        toastMessage: nil
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
        // MARK: Logic
        case .sendButtonDipTap:
            return sendMail(senderName: currentState.senderNameText,
                            content: currentState.letterContentsText,
                            recipientName: currentState.selectedAvatar?.name ?? "")
        case .hideToolTip:
            return Observable.just(Mutation.setIsTooltipHidden(isHidden: true))
        // recipient
        case .getAllAvatarInfos:
            return getAllAvatarInfos()
        case let .recipientNameTextDidChange(text: text):
            return Observable.concat([
                Observable.just(.setRecipientNameText(text: text)),
                getAllFilteredAvatarInfos(with: text,
                                          in: currentState.avatarInfos)
            ])
        case .clearFilteredAvatarInfos:
            return Observable.just(.setFilteredAvatarInfos(avatarInfos: []))
        case let .changeSelectedAvatar(avatar: avatar):
            return Observable.just(.setSelectedAvatar(avatarInfo: avatar))
        case .initializeRecipientStates:
            return Observable.of(
                .setRecipientNameText(text: ""),
                .setAvatarInfos(avatarInfos: []),
                .setFilteredAvatarInfos(avatarInfos: []),
                .setSelectedAvatar(avatarInfo: nil)
            )
        // letter contents
        case let .letterContentsTextDidChange(text: text):
            return Observable.just(Mutation.setLetterContentsText(text: text))
        case .initializeLetterContentStates:
            return Observable.of(
                .setLetterContentsText(text: "")
            )
        // sender
        case let .senderNameTextDidChange(text: text):
            return Observable.just(Mutation.setSenderNameText(text: text))
        case .initializeSenderStates:
            return Observable.of(
                .setSenderNameText(text: "")
            )
            
        // MARK: Navigation
        case .closeMailWritingController:
            coordinator.closeMailWritingController()
            return .empty()
        case .showAvatarSettingController:
            coordinator.showAvatarSettingController(with: nil)
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIsMailSent(isSent: isSent):
            newState.isMailSent = isSent
        case let .setIsTooltipHidden(isHidden: isHidden):
            newState.isTooltipHidden = isHidden
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        // recipient
        case  let .setRecipientNameText(text: text):
            newState.recipientNameText = text
        case let .setSelectedAvatar(avatarInfo: avatarInfo):
            newState.selectedAvatar = avatarInfo
        case let .setFilteredAvatarInfos(avatarInfos: avatarInfos):
            newState.filteredAvatarInfos = avatarInfos
        case let .setAvatarInfos(avatarInfos: avatarInfos):
            newState.avatarInfos = avatarInfos
        // letter contents
        case let .setLetterContentsText(text: text):
            newState.letterContentsText = text
        // sender
        case let .setSenderNameText(text: text):
            newState.senderNameText = text
        }
        
        return newState
    }
    
    
    private func sendMail(senderName: String,
                          content: String,
                          recipientName: String) -> Observable<Mutation> {
        
        // 발신인(사용자)의 이름이 없는 경우
        if senderName.isEmpty {
            return Observable.just(.setToastMessage(text: "편지를 보내는 사람의 이름을 입력하세요."))
        }
        // 선택된 수신인(아바타)이 없는 경우
        else if recipientName.isEmpty {
            return Observable.just(.setToastMessage(text: "편지를 받는 아바타를 선택하세요."))
        }
        // 편지의 내용이 없는 경우
        else if content.isEmpty {
            return Observable.just(.setToastMessage(text: "편지의 내용을 입력하세요."))
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
                        return Observable.of(
                            Mutation.setIsMailSent(isSent: false),
                            Mutation.setToastMessage(text: "편지를 보내는 과정에서 문제가 발생했습니다.")
                        )
                    }
            }
            .catch { error in
                print(error.localizedDescription)
                return Observable.of(
                    Mutation.setIsMailSent(isSent: false),
                    Mutation.setToastMessage(text: "아바타 정보를 불러오는 과정에서 문제가 발생했습니다.")
                )
            }
    }
    
    
    private func getAllAvatarInfos() -> Observable<Mutation> {
        return database.getAllAvatars()
            .map { avatarInfoObjects in
                return .setAvatarInfos(avatarInfos: avatarInfoObjects.map { $0.toEntity() })
            }
    }
    
    
    private func getAllFilteredAvatarInfos(with name: String,
                                           in avatarInfos: [AvatarInfo]) -> Observable<Mutation> {
        let filteredAvatars = avatarInfos.filter {
            ($0.name).contains(name)
        }
        print(filteredAvatars)
        
        return Observable.just(.setFilteredAvatarInfos(avatarInfos: filteredAvatars))
    }
}

