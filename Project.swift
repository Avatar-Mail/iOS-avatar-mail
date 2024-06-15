import ProjectDescription

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
                ]
            ),
            sources: ["AvatarMail/Sources/**"],
            resources: ["AvatarMail/Resources/**"],
            dependencies: [
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
            ]
        ),
    ]
)
