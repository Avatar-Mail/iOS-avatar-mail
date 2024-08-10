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
        
        container.register(OpenAIService.self) {
            _ in OpenAIService()
        }.inObjectScope(.container)
        
        container.register(RealmDatabase.self) {
            _ in RealmDatabase()
        }.inObjectScope(.container)
        
        container.register(AudioRecordingManager.self) {
            _ in AudioRecordingManager()
        }.inObjectScope(.container)
        
        container.register(AudioPlayingManager.self) {
            _ in AudioPlayingManager()
        }.inObjectScope(.container)
        
        container.register(StorageManager.self) {
            _ in StorageManager()
        }.inObjectScope(.container)
    }

    
    func getOpenAIService() -> OpenAIService! {
        return container.resolve(OpenAIService.self)
    }
    
    func getRealmDatabase() -> RealmDatabase! {
        return container.resolve(RealmDatabase.self)
    }
    
    func getAudioRecordingManager() -> AudioRecordingManager! {
        return container.resolve(AudioRecordingManager.self)
    }
    
    func getAudioPlayingManager() -> AudioPlayingManager! {
        return container.resolve(AudioPlayingManager.self)
    }
    
    func getStorageManager() -> StorageManager! {
        return container.resolve(StorageManager.self)
    }
}

