import ProjectDescription

let project = Project(
    name: "yandex-promocode-tca",
    targets: [
        .target(
            name: "yandex-promocode-tca",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.yandex-promocode-tca",
            infoPlist: "yandex-promocode-tca-Info.plist",
            sources: ["yandex-promocode-tca/Sources/**"],
            resources: ["yandex-promocode-tca/Resources/**"],
            dependencies: [
                .external(name: "PinLayout"),
//                .external(name: "swift-composable-architecture"),
            ]
        ),
    ]
)
