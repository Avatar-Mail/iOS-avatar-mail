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
        case sentMailCheckboxDidTap
        case receivedMailCheckboxDidTap
        case searchTextDidChange(String)
    }
    
    enum Mutation {
        case setMails(mails: [Mail])
        case setFiltedMail(filteredMails: [Mail])
        case setIsSentFromUser(isSentFromUser: Bool?)
        case setSearchText(searchText: String)
        case setToastMessage(text: String)
    }
    
    struct State {
        var mails: [Mail]
        var filteredMails: [Mail]
        
        var isSentFromUser: Bool?
        var searchText: String
        
        @Pulse var toastMessage: String?
    }
    
    let initialState = State(
        mails: [],
        filteredMails: [],
        
        isSentFromUser: nil,
        searchText: "",
        
        toastMessage: nil
    )
    
    
    // MARK: - Initialization
    var coordinator: MailListCoordinatorProtocol
    var database: RealmDatabaseProtocol
    
    init(
        coordinator: MailListCoordinatorProtocol,
        database: RealmDatabaseProtocol
    ) {
        self.coordinator = coordinator
        self.database = database
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case .getAllMails:
            return getAllMails()
        // Navigation
        case .closeMailListController:
            coordinator.closeMailListController()
            return .empty()
        case let .showRepliedMailController(mail: mail):
            coordinator.showRepliedMailController(with: mail)
            return .empty()
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
                
                return Observable.of(
                    Mutation.setMails(mails: mails),
                    Mutation.setFiltedMail(filteredMails: mails)
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
                if isSentFromUser != nil {
                    if !mail.recipientName.contains(searchText) {
                        return false
                    }
                } else {
                    if !(mail.senderName.contains(searchText) || mail.recipientName.contains(searchText)) {
                        return false
                    }
                }
            }
            
            return true
        }
        
        
        return Mutation.setFiltedMail(filteredMails: filteredMails)
    }
}


