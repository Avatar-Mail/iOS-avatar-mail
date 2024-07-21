//
//  AvatarSettingReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class AvatarSettingReactor: Reactor {

    enum Action {
        // Logic
        case saveInitialAvatarInfo(avatarInfo: AvatarInfo)
        case avatarNameDidChange(name: String)
        case avatarAgeDidChange(age: String?)
        case avatarSelfRoleDidChange(avatarRole: String?)
        case avatarUserRoleDidChange(userRole: String?)
        case avatarCharacteristicDidChange(characteristic: String?)
        case avatarParlanceDidChange(parlance: String?)
        case saveAvatarButtonDidTap
        // Navigation
        case closeAvatarSettingController
    }
    
    enum Mutation {
        case setInitialAvatarInfo(avatarInfo: AvatarInfo)
        case setAvatarName(name: String)
        case setAvatarAge(age: String?)
        case setAvatarSelfRole(avatarRole: String?)
        case setAvatarUserRole(userRole: String?)
        case setAvatarCharacteristic(characteristic: String?)
        case setAvatarParlance(parlance: String?)
        case setAvatarHasSaved(hasSaved: Bool)
        case setToastMessage(text: String)
    }
    
    struct State {
        var initialAvatarInfo: AvatarInfo?  // 최초 아바타 존재 여부
        
        var name: String                    // 이름
        var age: String?                    // 나이
        var avatarRole: String?             // 아바타의 역할(관계)
        var userRole: String?               // 사용자의 역할(관계)
        var characteristic: String?         // 성격
        var parlance: String?               // 말투
        
        var hasAvatarSaved: Bool            // 아바타 저장 여부
        
        @Pulse var toastMessage: String?
    }
    
    let initialState = State(
        initialAvatarInfo: nil,
        
        name: "",
        age: nil,
        avatarRole: nil,
        userRole: nil,
        characteristic: nil,
        parlance: nil,
        
        hasAvatarSaved: false,
        
        toastMessage: nil
    )
    
    
    // MARK: - Initialization
    var coordinator: AvatarSettingCoordinator
    var database: RealmDatabase
    
    init(
        coordinator: AvatarSettingCoordinator,
        database: RealmDatabase,
        avatar: AvatarInfo?
    ) {
        self.coordinator = coordinator
        self.database = database
        
        if let avatar {
            action.onNext(.saveInitialAvatarInfo(avatarInfo: avatar))
            action.onNext(.avatarNameDidChange(name: avatar.name))
            action.onNext(.avatarAgeDidChange(age: avatar.ageGroup))
            action.onNext(.avatarSelfRoleDidChange(avatarRole: avatar.relationship.avatar))
            action.onNext(.avatarUserRoleDidChange(userRole: avatar.relationship.user))
            action.onNext(.avatarCharacteristicDidChange(characteristic: avatar.characteristic))
            action.onNext(.avatarParlanceDidChange(parlance: avatar.parlance))
        }
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case let .saveInitialAvatarInfo(avatarInfo: avatarInfo):
            return Observable.just(.setInitialAvatarInfo(avatarInfo: avatarInfo))
        case let .avatarNameDidChange(name: name):
            return Observable.just(Mutation.setAvatarName(name: name))
        case let .avatarAgeDidChange(age: age):
            return Observable.just(Mutation.setAvatarAge(age: age))
        case let .avatarSelfRoleDidChange(avatarRole: avatarRole):
            return Observable.just(Mutation.setAvatarSelfRole(avatarRole: avatarRole))
        case let .avatarUserRoleDidChange(userRole: userRole):
            return Observable.just(Mutation.setAvatarUserRole(userRole: userRole))
        case let .avatarCharacteristicDidChange(characteristic: characteristic):
            return Observable.just(Mutation.setAvatarCharacteristic(characteristic: characteristic))
        case let .avatarParlanceDidChange(parlance: parlance):
            return Observable.just(Mutation.setAvatarParlance(parlance: parlance))
        case .saveAvatarButtonDidTap:
            let avatar = AvatarInfo(name: currentState.name,
                                    ageGroup: currentState.age,
                                    relationship: Relationship(avatar: currentState.avatarRole,
                                                               user: currentState.userRole),
                                    characteristic: currentState.characteristic,
                                    parlance: currentState.parlance,
                                    recordings: [])
            return saveAvatar(avatar)
        // Navigation
        case .closeAvatarSettingController:
            coordinator.closeAvatarSettingController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setInitialAvatarInfo(avatarInfo: avatarInfo):
            newState.initialAvatarInfo = avatarInfo
        case let .setAvatarName(name: name):
            newState.name = name
        case let .setAvatarAge(age: age):
            newState.age = age
        case let .setAvatarSelfRole(avatarRole: avatarRole):
            newState.avatarRole = avatarRole
        case let .setAvatarUserRole(userRole: userRole):
            newState.userRole = userRole
        case let .setAvatarCharacteristic(characteristic: characteristic):
            newState.characteristic = characteristic
        case let .setAvatarParlance(parlance: parlance):
            newState.parlance = parlance
        case let .setAvatarHasSaved(hasSaved: hasSaved):
            newState.hasAvatarSaved = hasSaved
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    
    private func saveAvatar(_ avatar: AvatarInfo) -> Observable<Mutation> {
        
        guard avatar.name.isNotEmpty else {
            return Observable.just(.setToastMessage(text: "아바타 이름을 입력하세요."))
        }
        
        let avatarObject = AvatarInfoObject(avatar: avatar)
        
        return database.saveAvatar(avatarObject)
            .flatMap { toastMessage in
                return Observable.of(
                    Mutation.setToastMessage(text: toastMessage),
                    Mutation.setAvatarHasSaved(hasSaved: true)
                )
            }
            .catch { error in
                return Observable.just(.setToastMessage(text: error.localizedDescription))
            }
    }
}



