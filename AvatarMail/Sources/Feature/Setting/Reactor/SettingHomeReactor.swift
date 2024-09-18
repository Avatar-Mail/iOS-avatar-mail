//
//  SettingHomeReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 9/18/24.
//

import Foundation
import ReactorKit

class SettingHomeReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var settingHomeItems: [SettingHomeItem]
    }
    
    let initialState = State(
        settingHomeItems: [
            SettingHomeItem(id: .appVersion,
                            title: "앱 버전",
                            subTitle: "1.0.0",
                            showArrowIcon: false),
            SettingHomeItem(id: .debugMode,
                            title: "개발자 모드",
                            subTitle: nil,
                            showArrowIcon: true)
        ]
    )
    
    
    // MARK: - Initialization
    var coordinator: SettingHomeCoordinatorProtocol
    
    init(
        coordinator: SettingHomeCoordinatorProtocol
    ) {
        self.coordinator = coordinator
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            // Logic
            
            // Navigation
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


