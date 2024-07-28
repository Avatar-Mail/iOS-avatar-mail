//
//  AppDelegate.swift
//  IOSAvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit
import AVFoundation
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 의존성 초기화
        AppContainer.shared.registerDepedencies()
        
        // 오디오 세션 설정
        setupAudioSession()

        window = UIWindow(frame: UIScreen.main.bounds) // 변경된 부분
        window?.rootViewController = CustomTabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupAudioSession() {
        // AudioSession Setup
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            fatalError("AudioSession Initialization Error")
        }
    }
    
    private func setupRealmDatabase() {
        // Realm 스키마 버전
        let schemaVersion: UInt64 = 1

        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < schemaVersion {
                    
                    // Migration Logic
                    // 참고 : https://1000one.tistory.com/57
                    
                    migration.enumerateObjects(ofType: AvatarInfoObject.className()) { oldObject, newObject in
                        // recordings 속성이 새로 추가되었기 때문에 기본값을 설정합니다.
                        if newObject!["recordings"] == nil {
                            newObject!["recordings"] = List<AudioRecordingObject>()
                        }
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config
    }
}


