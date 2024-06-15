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
            dependencies: []
        ),
    ]
)
