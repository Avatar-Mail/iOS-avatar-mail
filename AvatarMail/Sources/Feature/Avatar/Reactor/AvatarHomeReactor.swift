//
//  AvatarHomeReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class AvatarHomeReactor: Reactor {
    
    enum Action {
        case syncQueryToSearchTextFieldInput(text: String)
        case getAllAvatarInfos
        case clearFilteredAvatarInfos
        case changeSelectedAvatar(avatar: AvatarInfo)
        case initializeAllStates
        case showAvatarSettingController
    }
    
    enum Mutation {
        case setQuery(query: String)
        case setSelectedAvatar(avatarInfo: AvatarInfo?)
        case setFilteredAvatarInfos(avatarInfos: [AvatarInfo])
        case setAvatarInfos(avatarInfos: [AvatarInfo])
    }
    
    struct State {
        var query: String
        var selectedAvatar: AvatarInfo?
        var avatarInfos: [AvatarInfo]
        var filteredAvatarInfos: [AvatarInfo]
    }
    
    let initialState = State(
        query: "",
        selectedAvatar: nil,
        avatarInfos: [],
        filteredAvatarInfos: []
    )
    
    
    // MARK: - Initialization
    var coordinator: AvatarHomeCoordinatorProtocol
    var database: RealmDatabaseProtocol
    
    init(
        coordinator: AvatarHomeCoordinatorProtocol,
        database: RealmDatabaseProtocol
    ) {
        self.coordinator = coordinator
        self.database = database
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case .getAllAvatarInfos:
            return getAllAvatarInfos()
        case let .syncQueryToSearchTextFieldInput(text: text):
            return Observable.concat([
                Observable.just(.setQuery(query: text)),
                getAllFilteredAvatarInfos(with: text,
                                          in: currentState.avatarInfos)
            ])
        case .clearFilteredAvatarInfos:
            return Observable.just(.setFilteredAvatarInfos(avatarInfos: []))
        case let .changeSelectedAvatar(avatar: avatar):
            return Observable.just(.setSelectedAvatar(avatarInfo: avatar))
        case .initializeAllStates:
            return Observable.of(
                .setQuery(query: ""),
                .setAvatarInfos(avatarInfos: []),
                .setFilteredAvatarInfos(avatarInfos: []),
                .setSelectedAvatar(avatarInfo: nil)
            )
        // Navigation
        case .showAvatarSettingController:
            coordinator.showAvatarSettingController(with: currentState.selectedAvatar)
            return .empty()
        }
        
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSelectedAvatar(avatarInfo: avatarInfo):
            newState.selectedAvatar = avatarInfo
        case let .setAvatarInfos(avatarInfos: avatarInfos):
            newState.avatarInfos = avatarInfos
        case let .setFilteredAvatarInfos(avatarInfos: avatarInfos):
            newState.filteredAvatarInfos = avatarInfos
        case let .setQuery(query: query):
            newState.query = query
        }
        
        return newState
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
        
        return Observable.just(.setFilteredAvatarInfos(avatarInfos: filteredAvatars))
    }
}

