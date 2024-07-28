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
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var writtenMail: Mail?
    }
    
    var initialState: State
    
    
    // MARK: - Initialization
    var coordinator: RepliedMailCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    
    init(
        coordinator: RepliedMailCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol,
        mail: Mail
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
        self.initialState = State(writtenMail: mail)
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
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        }
        
        return newState
    }
}

