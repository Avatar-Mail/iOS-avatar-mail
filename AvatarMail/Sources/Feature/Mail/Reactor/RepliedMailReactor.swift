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
        case getRepliedMail
        case replyButtonDidTap
    }
    
    enum Mutation {
        case setRepliedMail(mail: Mail)
    }
    
    struct State {
        var repliedMail: Mail?
    }
    
    let initialState = State(
        repliedMail: nil
    )
    
    
    // MARK: - Initialization
    var coordinator: RepliedMailCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    
    init(
        coordinator: RepliedMailCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case .getRepliedMail:
            return .empty()
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
        case let .setRepliedMail(mail: mail):
            newState.repliedMail = mail
        }
        
        return newState
    }
}

