//
//  AppContainer.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import Swinject

class AppContainer {
    static let shared = AppContainer()
    private let container = Container()
    
    private init() {}
    
    // MARK: 의존성 등록 메서드 (초기화)
    func registerDepedencies() {
        // OpenAIService
        container.register(OpenAIService.self) {
            _ in OpenAIService()
        }.inObjectScope(.container)
        
        container.register(RealmDatabase.self) {
            _ in RealmDatabase()
        }.inObjectScope(.container)
    }

    
    func getOpenAIService() -> OpenAIService! {
        return container.resolve(OpenAIService.self)
    }
    
    func getRealmDatabase() -> RealmDatabase! {
        return container.resolve(RealmDatabase.self)
    }
}

