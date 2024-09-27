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
        case showToast(text: String)
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
    var database: RealmDatabaseProtocol
    var ttsAdapter: TTSAdapterProtocol
    
    init(
        coordinator: MailWritingCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol,
        database: RealmDatabaseProtocol,
        ttsAdapter: TTSAdapterProtocol
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
        self.database = database
        self.ttsAdapter = ttsAdapter
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
        case let .showToast(text: text):
            return Observable.just(Mutation.setToastMessage(text: text))
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
        
        let avatarName = recipientName  // 수신인 이름 -> 아바타 이름

        // (1) 주어진 recipientName으로, 해당 이름을 갖는 아바타가 있으면 해당 아바타를 가져와서 AvatarInfo를 세팅
        return database.getAvatar(withName: avatarName)
            .flatMap { [weak self] avatarInfoObject -> Observable<Mutation> in
                guard let self else { return .empty() }
                
                let avatarInfo = avatarInfoObject.toEntity()
                
                let mail = Mail(id: UUID().uuidString,
                                recipientName: recipientName,
                                content: content,
                                senderName: senderName,
                                date: Date(),
                                isSentFromUser: true)
                
                // (2) 편지 본문과 아바타 정보를 OpenAI API로 넘겨 답장 편지 내용을 Response로 받음
                return openAIService.sendMail2(mail: mail,
                                              avatarInfo: avatarInfo)
                    .flatMap { openAIResponse in
                        
                        let repliedMailContent = openAIResponse.content
                        let repliedMailID = UUID().uuidString
                        var repliedMail = Mail(id: repliedMailID,
                                                recipientName: senderName,
                                                content: repliedMailContent,
                                                senderName: recipientName,
                                                date: Date(),
                                                isSentFromUser: false)
                        
                        // (3) 서버에 편지 정보를 보내서, 이후에 응답 편지 리스트 페이지 진입할 때 나레이션 음성 파일을 Response로 받음
                        return self.ttsAdapter.sendMail(mailID: repliedMailID,
                                                        avatarID: avatarInfo.id,
                                                        content: repliedMailContent)
                            .flatMap { response in
                                // (4) 보낸 편지와 받은 편지를 모두 로컬 DB에 저장한다.
                                let saveMailObservable = self.database.saveMail(MailObject(mail: mail))
                                let saveRepliedMailObservable = self.database.saveMail(MailObject(mail: repliedMail))
                                
                                return Observable.zip(saveMailObservable, saveRepliedMailObservable)
                                    .flatMap { _ in
                                        return Observable.of(
                                            Mutation.setIsMailSent(isSent: true),
                                            Mutation.setToastMessage(text: response.message ?? "편지를 보내는 데 성공했습니다.")
                                        )
                                    }
                                    .catch { error in
                                        print(error.localizedDescription)
                                        return Observable.of(
                                            Mutation.setIsMailSent(isSent: false),
                                            Mutation.setToastMessage(text: "편지를 저장하는 과정에서 문제가 발생했습니다.")
                                        )
                                    }
                            }
                            .catch { error in
                                let networkError = RefactoredNetworkServiceError(error: error)
                                return Observable.of(
                                    Mutation.setIsMailSent(isSent: false),
                                    Mutation.setToastMessage(text: networkError.message ?? "서버에 편지를 보내는 과정에서 문제가 발생했습니다.")
                                )
                            }
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

