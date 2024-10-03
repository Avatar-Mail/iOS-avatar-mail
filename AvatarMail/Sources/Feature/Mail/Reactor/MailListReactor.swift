//
//  MailListReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation
import ReactorKit

class MailListReactor: Reactor {
    
    enum Action {
        case getAllMails
        case closeMailListController
        case showRepliedMailController(mail: Mail)
        case openMailWritingController
        case sentMailCheckboxDidTap
        case receivedMailCheckboxDidTap
        case searchTextDidChange(String)
        case clearFilter
        case getAllAudioFileNames
    }
    
    enum Mutation {
        case setMails(mails: [Mail])
        case setFiltedMail(filteredMails: [Mail])
        case setIsSentFromUser(isSentFromUser: Bool?)
        case setSearchText(searchText: String)
        case setToastMessage(text: String)
        case setAudioFileNames(audioFileNames: [String])
    }
    
    struct State {
        var existingAudioFileNames: [String]?  // 파일 이름 리스트 (해당 리스트에 존재하는 파일만 리스트에)
        var mails: [Mail]
        var filteredMails: [Mail]
        
        var isSentFromUser: Bool?
        var searchText: String
        
        @Pulse var toastMessage: String?
    }
    
    let initialState = State(
        existingAudioFileNames: nil,
        
        mails: [],
        filteredMails: [],
        
        isSentFromUser: nil,
        searchText: "",
        
        toastMessage: nil
    )
    
    
    // MARK: - Initialization
    var coordinator: MailListCoordinatorProtocol
    var database: RealmDatabaseProtocol
    var ttsAdapter: TTSAdapterProtocol
    
    init(
        coordinator: MailListCoordinatorProtocol,
        database: RealmDatabaseProtocol,
        ttsAdapter: TTSAdapterProtocol
    ) {
        self.coordinator = coordinator
        self.database = database
        self.ttsAdapter = ttsAdapter
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case .getAllMails:
            return getAllMails()
        case .sentMailCheckboxDidTap:
            if currentState.isSentFromUser == true {
                return Observable.of(
                    Mutation.setIsSentFromUser(isSentFromUser: nil),
                    getFilteredMailMutation(isSentFromUser: nil, searchText: currentState.searchText)
                )
            } else {
                return Observable.of(
                    Mutation.setIsSentFromUser(isSentFromUser: true),
                    getFilteredMailMutation(isSentFromUser: true, searchText: currentState.searchText)
                )
            }
        case .receivedMailCheckboxDidTap:
            if currentState.isSentFromUser == false {
                return Observable.of(
                    Mutation.setIsSentFromUser(isSentFromUser: nil),
                    getFilteredMailMutation(isSentFromUser: nil, searchText: currentState.searchText)
                )
            } else {
                return Observable.of(
                    Mutation.setIsSentFromUser(isSentFromUser: false),
                    getFilteredMailMutation(isSentFromUser: false, searchText: currentState.searchText)
                )
            }
        case .searchTextDidChange(let searchText):
            return Observable.of(
                Mutation.setSearchText(searchText: searchText),
                getFilteredMailMutation(isSentFromUser: currentState.isSentFromUser, searchText: searchText)
            )
        case .clearFilter:
            return Observable.of(
                Mutation.setFiltedMail(filteredMails: currentState.mails),
                Mutation.setIsSentFromUser(isSentFromUser: nil),
                Mutation.setSearchText(searchText: "")
            )
        case .getAllAudioFileNames:
            return getAllAudioFileNames()
        // Navigation
        case .closeMailListController:
            coordinator.closeMailListController()
            return .empty()
        case .openMailWritingController:
            coordinator.openMailWritingController()
            return .empty()
        case let .showRepliedMailController(mail: mail):
            coordinator.showRepliedMailController(with: mail)
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setMails(mails: mails):
            newState.mails = mails
        case let .setFiltedMail(filteredMails: filteredMails):
            newState.filteredMails = filteredMails
        case let .setIsSentFromUser(isSentFromUser: isSentFromUser):
            newState.isSentFromUser = isSentFromUser
        case let .setSearchText(searchText: searchText):
            newState.searchText = searchText
        case let .setAudioFileNames(audioFileNames: audioFileNames):
            newState.existingAudioFileNames = audioFileNames
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    private func getAllMails() -> Observable<Mutation> {
        return database.getAllMails()
            .flatMap { mailObjects in
                // 날짜 최신순 정렬
                let mails = mailObjects.map { $0.toEntity() }.sorted(by: { $0.date > $1.date })
                var filteredMails: [Mail] = []
                let existingAudioFileNames = self.currentState.existingAudioFileNames
                
                print("mails: \(mails.map { $0.id })")
                print("exists: \(existingAudioFileNames)")
                
                if let existingAudioFileNames {
                    for mail in mails {
                        if mail.isSentFromUser == false && !existingAudioFileNames.contains(mail.id) {
                            // 아바타가 보낸 메일 중에서 existingAudioFileNames에 id가 포함되지 않은 메일은 스킵
                            continue
                        }
                        
                        filteredMails.append(mail)
                    }
                } else {
                    filteredMails = mails.filter { $0.isSentFromUser == true }
                }
                
                print("filtered: \(filteredMails.map { $0.id })")
                
                return Observable.of(
                    Mutation.setMails(mails: filteredMails),
                    Mutation.setFiltedMail(filteredMails: filteredMails)
                )
            }
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(.setToastMessage(text: "편지 목록을 불러오는 데 실패했습니다."))
            }
    }
    
    private func getFilteredMailMutation(isSentFromUser: Bool?, searchText: String) -> Mutation {
        let mailsToFilter = currentState.mails
        
        let filteredMails = mailsToFilter.filter { mail in
            // 보낸 대상(사용자/아바타)이 다르면 패스
            if let isSentFromUser,
               isSentFromUser != mail.isSentFromUser {
                return false
            }
            // 검색 문자열 포함되지 않으면 패스
            if searchText.isNotEmpty {
                if !(mail.senderName.contains(searchText) || mail.recipientName.contains(searchText)) {
                    return false
                }
            }
            
            return true
        }
        
        return Mutation.setFiltedMail(filteredMails: filteredMails)
    }
    
    func getAllAudioFileNames() -> Observable<Mutation> {
        return ttsAdapter.getNarrationAudioFileNames()
            .flatMap { response -> Observable<Mutation> in
                
                guard let data = response.data else {
                    return Observable.just(Mutation.setAudioFileNames(audioFileNames: []))
                }
                
                // data가 [String] 타입으로 내려오기 때문에, 별도로 파싱 X
                let fileNames = data
                
                if fileNames.isNotEmpty {
                    return Observable.just(Mutation.setAudioFileNames(audioFileNames: fileNames))
                } else {
                    return Observable.just(Mutation.setAudioFileNames(audioFileNames: []))
                }
            }
            .catch { error in
                return Observable.of(
                    Mutation.setToastMessage(text: "편지 음성 파일 목록을 불러오는 데 실패했습니다."),
                    Mutation.setAudioFileNames(audioFileNames: [])
                )
            }
    }

}


