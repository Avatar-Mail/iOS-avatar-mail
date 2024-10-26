import UIKit
import AVFoundation
import RealmSwift
import UserNotifications
import Firebase
import FirebaseMessaging
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 의존성 초기화
        AppContainer.shared.registerDepedencies()
        
        // 오디오 세션 설정
        setupAudioSession()
        
        // Realm 데이터베이스 설정
        setupRealmDatabase()
        
        // 파이어베이스 설정
        setupFirebase()
        
        // 푸시 알림 설정
        setupPushNotification(with: application)
        
        print(String.deviceID)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CustomTabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            GlobalDialog.shared.show(title: "오디오 연결 실패",
                                     description: "오디오를 연결할 수 없습니다. 현재 오디오를 실행 중인 앱을 닫고 앱을 재시작하세요.",
                                     buttonInfos:
                                        .init(title: "확인",
                                              titleColor: .white,
                                              backgroundColor: UIColor(hex: 0x336FF2),
                                              borderColor: nil,
                                              buttonHandler: {
                                                  GlobalDialog.shared.hide()

                                                  UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                      exit(0)
                                                  }
                                              }))
        }
    }
    
    private func setupRealmDatabase() {
        let schemaVersion: UInt64 = 1

        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < schemaVersion {
                    migration.enumerateObjects(ofType: AvatarInfoObject.className()) { oldObject, newObject in
                        if newObject?["recordings"] == nil {
                            newObject?["recordings"] = List<AudioRecordingObject>()
                        }
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupPushNotification(with application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        DispatchQueue.global(qos: .userInitiated).async {
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, error in
                    if let error = error {
                        print("Failed to request authorization for notifications: \(error.localizedDescription)")
                        return
                    }
                    
                    guard granted else {
                        print("User denied notification permissions")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            )
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications with token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Laon - PushNoti to Show")
        
        // 신규 편지 수신 Notification 이벤트 방출
        NotificationCenter.default.post(name: .replyMailReceived, object: nil)
        // 미확인 신규 편지 존재 여부를 true로 변경 (-> TopNavigation에 red dot 노출)
        UserDefaults.standard.set(true, forKey: AppConst.shared.isUncheckedReplyMailExists)
        
        completionHandler([.badge, .banner, .list, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // FCM 토큰을 서버에 전달
        let userAdapter = AppContainer.shared.getUserAdapter()
        
        guard let token = Messaging.messaging().fcmToken else { fatalError("FCM 토큰을 찾을 수 없습니다.") }
        
        Task {
            await FirestoreDatabase.shared.loadBaseServerURL()
            
            userAdapter?.sendFCMToken(fcmToken: token)
                .subscribe(
                    onNext: { _ in
                        print("FCMS 토큰 전송 성공 - Token: \(token)")
                    },
                    onError: { error in
                        print("FCMS 토큰 전송 실패 - Error: \(error.localizedDescription)")

                        GlobalDialog.shared.show(title: "연결 실패",
                                                 description: "서버에 연결할 수 없습니다. 네트워크 연결 상태를 확인하시고 다시 접속을 시도해주세요.",
                                                 buttonInfos:
                                                    .init(title: "확인",
                                                          titleColor: .white,
                                                          backgroundColor: UIColor(hex: 0x336FF2),
                                                          borderColor: nil,
                                                          buttonHandler: {
                                                              GlobalDialog.shared.hide()
                            
                                                              UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                                              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                  exit(0)
                                                              }
                                                          }))
                    }
                ).disposed(by: self.disposeBag)
        }
    }
}
