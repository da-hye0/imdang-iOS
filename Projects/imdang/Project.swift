import ProjectDescription

let googleServiceInfoScript = TargetScript.post(
    script: """
    case "${CONFIGURATION}" in
      "Debug" )
        cp -r "$SRCROOT/Resources/GoogleService-Info-Debug.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
      "Release" )
        cp -r "$SRCROOT/Resources/GoogleService-Info-Release.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
    *)
      ;;
    esac
    """,
    name: "Setup Firebase Environment GoogleService-info.plist",
    basedOnDependencyAnalysis: false
)

let project = Project(
    name: "imdang",
    targets: [
        .target(
            name: "imdang",
            destinations: .iOS,
            product: .app,
            bundleId: "info.apt.imdang",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleShortVersionString": "1.0.1",
                    "CFBundleVersion": "1",
                    "UIUserInterfaceStyle": "Light",
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "LSApplicationQueriesSchemes" : [
                        "kakaokompassauth",
                        "kakaolink",
                        "kakaoplus",
                        "kakaotalk",
                        "nmap",
                        "imdang"
                    ],
                    "CFBundleURLTypes" : [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["$(KAKAO_URL_KEY)"]
                        ],
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["$(GOOGLE_URL_KEY)"]
                        ],
                    ],
                    "CFBundleDisplayName" : "아파트임당",
                    "KAKAO_URL_KEY": "$(KAKAO_URL_KEY)",
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
                    "NAVER_APP_KEY_ID": "$(NAVER_APP_KEY_ID)",
                    "NAVER_APP_KEY": "$(NAVER_APP_KEY)",
                    "WELCOME_COUPON": "$(WELCOME_COUPON)",
                    "IMDANG_API": "$(IMDANG_API)",
                    "IMDANG_DEV_API": "$(IMDANG_DEV_API)",
                    "NSCameraUsageDescription": "카메라를 사용하여 인사이트 사진을 업로드합니다.",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "UIBackgroundModes": ["remote-notification"]

                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "Resources/**",
                "Sources/App/LaunchScreen.storyboard",
            ],
            entitlements: "imdang.entitlements",
            scripts: [googleServiceInfoScript],
            dependencies: [
                .external(name: "Kingfisher"),
                .external(name: "Alamofire"),
                .external(name: "Then"),
                .external(name: "SnapKit"),
                .external(name: "ReactorKit"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
                .external(name: "RxKakaoSDK"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseDynamicLinks"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebasePerformance"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "NMapsMap"),
                .external(name: "SkeletonView"),
                .project(target: "NetworkKit", path: "../NetworkKit"),
                .target(name: "SharedLibraries")
            ],
            settings: .settings(
                // 하.. 구글로그인 에러 3시간동안 안되서 찾으니 tuist objc 충돌 이거쓰면 된다네요
                base: ["OTHER_LDFLAGS":["-all_load -Objc"]],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Config/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "Config/Release.xcconfig")
                ]
            )
        ),
        .target(
            name: "imdangTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "info.apt.imdangTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "imdang")]
        ),
        .target(
            name: "SharedLibraries",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "info.imdang.SharedLibraries",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: [],
            dependencies: [
                .external(name: "FirebaseAuth"),
                .external(name: "GoogleSignIn"),
            ]
        ),
    ]
)
