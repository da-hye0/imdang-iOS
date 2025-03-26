import UIKit
import RxKakaoSDKCommon
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOption,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        if let APIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String {
            RxKakaoSDK.initSDK(appKey: APIKey)
        }
        
        if let APIKey = Bundle.main.object(forInfoDictionaryKey: "NAVER_APP_KEY_ID") as? String {
            NMFAuthManager.shared().clientId = APIKey
        }
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let _ = error {
                return
            }

            if let _ = user {
            } else {
            }
        }
        
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "None")")

        if let token = fcmToken {
            UserdefaultKey.deviceToken = token
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}
