//
//  MailHomeReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class MailHomeReactor: Reactor {
    
    enum Action {
        case showMailWritingController
        case showMailListController
    }
    
    enum Mutation {
        case setRepliedMailExists(exists: Bool)
    }
    
    struct State {
        var repliedMailExists: Bool
    }
    
    let initialState = State(
        repliedMailExists: false
    )
    
    
    // MARK: - Initialization
    var coordinator: MailHomeCoordinatorProtocol
    var openAIService: OpenAIServiceProtocol
    
    init(
        coordinator: MailHomeCoordinatorProtocol,
        openAIService: OpenAIServiceProtocol
    ) {
        self.coordinator = coordinator
        self.openAIService = openAIService
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
            
        // Navigation
        case .showMailWritingController:
            coordinator.showMailWritingController()
            return .empty()
        case .showMailListController:
            coordinator.showMailListController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setRepliedMailExists(exists: exists):
            newState.repliedMailExists = exists
        }
        
        return newState
    }
}

