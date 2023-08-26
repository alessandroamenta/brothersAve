import UIKit
import Quickblox
import FirebaseCore
import CoreLocation
import FirebaseAuth
import QuickbloxWebRTC
import FirebaseMessaging
import IQKeyboardManager
import UserNotifications
import NotificationCenter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var email = ""
    var password = ""
    var lat: Double?
    var long: Double?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var category = "food"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setUpFirebase()
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        registerForRemoteNotifications(application: application)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        Messaging.messaging().delegate = self
        
        QBSettings.applicationID = 100396
        QBSettings.authKey = "DgCcgCBg4HcV2wJ"
        QBSettings.authSecret = "MGpYvsYryf-GsNt"
        QBSettings.accountKey = "3vWEMd9CZ2-8N8nZVZzX"
        QBSettings.autoReconnectEnabled = true
        GoogleApi.shared.initialiseWithKey("AIzaSyDprcLjl61IceP71MTMcrHYw-szHkiv-U4")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        //Quickblox.initWithApplicationId(99443, authKey: "x9J8Y4KxbFpqJ6p", authSecret: "aa9J2qkecbv5UzT", accountKey: "-71pqQvDfUFmnXTK8mR3")
        IQKeyboardManager.shared().isEnabled = true
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // set the value of lat and long
        lat = location.latitude
        long = location.longitude
        //print("Lat: \(String(describing: lat)) Long: \(String(describing: long))")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }
}

extension AppDelegate {
    
    ///setUpFirebase...
    func setUpFirebase() { FirebaseApp.configure() }

}

//MARK:- MessagingDelegate...
extension AppDelegate: MessagingDelegate {
    
    //didReceiveRegistrationToken...
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Constants.appCredentials.fcmToken = ""
        Constants.appCredentials.fcmToken = fcmToken
    }
     
}


//MARK:- UNUserNotificationCenterDelegate...
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // willPresent...
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void) {
        let _ = notification.request.content.userInfo
        completionHandler([[.alert, .badge, .sound]])
    }
    
    //didReceive...
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        //let userInfo = response.notification.request.content.userInfo
        //let title = (userInfo["title"] as? String ?? ""); let body = (userInfo["body"] as? String ?? "")
        //let type = (userInfo["type"] as? String ?? ""); let type_id = (userInfo["type_id"] as? String ?? "")
        //print(title); print(body); print(type); print(type_id)
        completionHandler()
    }
    
    /// RegisterForRemoteNotifications...
    func registerForRemoteNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            /// For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }
    
    
    // Lock the orientation to Portrait mode
       func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
           return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
       }
    
}
