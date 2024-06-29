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
        case showRepliedMailController
        case checkRepliedMailExists
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
        case .checkRepliedMailExists:
            return checkRepliedMailExists()
        // Navigation
        case .showMailWritingController:
            coordinator.showMailWritingController()
            return .empty()
        case .showRepliedMailController:
            coordinator.showRepliedMailController()
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
    
    
    private func checkRepliedMailExists() -> Observable<Mutation> {
        return openAIService.checkRepliedMailExists()
            .flatMap { response in
                return Observable.just(.setRepliedMailExists(exists: response))
            }.catch { error in
                print(error.localizedDescription)
                return .empty()
            }
    }
}

