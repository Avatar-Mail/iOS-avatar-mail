import ProjectDescription

let project = Project(
    name: "IOSAvatarMail",
    targets: [
        .target(
            name: "IOSAvatarMail",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.IOSAvatarMail",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["IOSAvatarMail/Sources/**"],
            resources: ["IOSAvatarMail/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "IOSAvatarMailTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.IOSAvatarMailTests",
            infoPlist: .default,
            sources: ["IOSAvatarMail/Tests/**"],
            resources: [],
            dependencies: [.target(name: "IOSAvatarMail")]
        ),
    ]
)
