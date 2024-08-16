import UIKit
import AVFoundation
import RealmSwift
import UserNotifications
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
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
            fatalError("AudioSession Initialization Error: \(error)")
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
        
        application.registerForRemoteNotifications()

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
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
            }
        )
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications")
        Messaging.messaging().apnsToken = deviceToken
        
        // 이게 FCMS 토큰
        // TODO: 토큰 저장했다가 서버에 전달
        print(Messaging.messaging().fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
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
        
        // TODO: If necessary send token to application server.
    }
}
