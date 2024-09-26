import ProjectDescription

let projectSettings: Settings = .settings(
    base: [
        "OTHER_LDFLAGS": ["-ObjC -all_load"],
        "DEVELOPMENT_TEAM": "$(TEAM_ID)"
    ],
    configurations: [
        .debug(name: "Debug", xcconfig: "./XCConfig/DEV.xcconfig"),
        .release(name: "Release", xcconfig: "./XCConfig/PROD.xcconfig"),
    ]
)

let project = Project(
    name: "AvatarMail",
    targets: [
        .target(
            name: "AvatarMail",
            destinations: .iOS,
            product: .app,
            bundleId: "com.AvatarMail",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "APIKey": "$(OPEN_API_KEY)",
                    "AppVersion": "$(APP_VERSION)",
                    "BaseURL": "BASE_SERVER_URL",
                    "NSMicrophoneUsageDescription": "This app requires access to the microphone to record audio.",
                    // FIXME: 배포할 땐 false로 바꾸자 (localhost HTTP load 허용)
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            "localhost": [
                                "NSTemporaryExceptionAllowsInsecureHTTPLoads": false
                            ]
                        ]
                    ],
                    "UIAppFonts": [
                        "ChosunKm.TTF",
                        "ChosunNm.ttf",
                        "ChosunSm.TTF",
                        
                        "Pretendard-Black.otf",
                        "Pretendard-ExtraBold.otf",
                        "Pretendard-Bold.otf",
                        "Pretendard-SemiBold.otf",
                        "Pretendard-Medium.otf",
                        "Pretendard-Regular.otf",
                        "Pretendard-Light.otf",
                        "Pretendard-ExtraLight.otf",
                        "Pretendard-Thin.otf"
                    ],
                    "UIBackgroundModes": [
                        "fetch",
                        "remote-notification",
                        "processing"
                    ],
                    "FirebaseAppDelegateProxyEnabled": false,
                    // 화면 가로 모드 방지
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ]
                ]
            ),
            sources: ["AvatarMail/Sources/**"],
            resources: [
                "AvatarMail/Resources/**",
                "AvatarMail/Resources/Fonts/*.ttf"
            ],
            entitlements: "AvatarMail/Resources/AvatarMail.entitlements",
            dependencies: [
                // SDK
                .external(name: "FirebaseFirestore", condition: .none),
                .external(name: "FirebaseMessaging", condition: .none),
                .external(name: "FirebaseAnalytics", condition: .none),
                // API
                .external(name: "OpenAI", condition: .none),
                // DB
                .external(name: "Realm", condition: .none),
                .external(name: "RealmSwift", condition: .none),
                // Network
                .external(name: "Alamofire", condition: .none),
                // Rx
                .external(name: "RxSwift", condition: .none),
                .external(name: "RxCocoa", condition: .none),
                .external(name: "RxOptional", condition: .none),
                .external(name: "RxGesture", condition: .none),
                // Architecture
                .external(name: "ReactorKit", condition: .none),
                // DI
                .external(name: "Swinject", condition: .none),
                // UI
                .external(name: "SnapKit", condition: .none),
                .external(name: "Then", condition: .none),
                .external(name: "Toast", condition: .none),
                .external(name: "Lottie", condition: .none),
                // ETC
                .external(name: "SwiftKeychainWrapper", condition: .none)
            ],
            settings: projectSettings
        ),
    ]
)
