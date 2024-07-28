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
    }
    
    enum Mutation {
        case setMails(mails: [Mail])
        case setToastMessage(text: String)
    }
    
    struct State {
        var mails: [Mail]
        var filteredMails: [Mail]
        
        @Pulse var toastMessage: String?
    }
    
    let initialState = State(
        mails: [],
        filteredMails: [],
        
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
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setMails(mails: mails):
            newState.mails = mails
            newState.filteredMails = mails
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    private func getAllMails() -> Observable<Mutation> {
        return database.getAllMails()
            .flatMap { mailObjects in
                return Observable.just(.setMails(mails: mailObjects.map { $0.toEntity() }))
            }
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(.setToastMessage(text: "편지 목록을 불러오는 데 실패했습니다."))
            }
    }
}


