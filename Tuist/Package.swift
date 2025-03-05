// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        productTypes: [
            "PinLayout": .framework,
            "ComposableArchitecture": .framework,
        ]
    )
#endif

let package = Package(
    name: "yandex-promocode-tca",
    dependencies: [
        .package(url: "https://github.com/layoutBox/PinLayout", exact: "1.10.5"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.18.0"),
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
