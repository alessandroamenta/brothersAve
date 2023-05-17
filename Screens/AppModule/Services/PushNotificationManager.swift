//
//  PushNotificationManager.swift
//  Wind Searched
//
//  Created by Hamza Shahbaz on 30/04/2021.
//  Copyright © 2021 Hamza Shahbaz. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications
import LocalAuthentication

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var defaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let notificationDelegate = SampleNotificationDelegate()
    
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            center.delegate = notificationDelegate
            let openAction = UNNotificationAction(identifier: "OpenNotification", title: NSLocalizedString("Open", comment: "Press to open app"), options: UNNotificationActionOptions.foreground)
            let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [openAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories(Set([deafultCategory]))

            Messaging.messaging().delegate = self
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    let usersRef = Firestore.firestore().collection("users").document(self.userID)
                    usersRef.setData(["fcmToken": token], merge: true)
                    if self.defaults.bool(forKey: "WatchWalkThrough") == true {
                        // setupNotification()
                    }
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
            usersRef.setData(["deviceType": "ios"],merge: true)
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Coming hereeee/÷÷÷÷÷//")
        NotificationCenter.default.post(name: TO_NOTIF_NTOFICATION_RECIEVED, object: nil, userInfo: nil)
        print(response)
        completionHandler()
    }
    
}




class SampleNotificationDelegate: NSObject , UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Open Action")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("default")
        }
        completionHandler()
    }
}
