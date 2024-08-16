// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [:]
    )
#endif

let package = Package(
    name: "AvatarMail",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/realm/realm-swift", .upToNextMajor(from: "10.51.0")),
        .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "0.2.9"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.4"),
        .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.5"),
        .package(url: "https://github.com/devxoul/Then.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", from: "5.1.1"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.24.0")
    ]
)
