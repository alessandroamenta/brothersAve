//
//  Storyboards.swift
//  Propert App
//
//  Created by Syed Saood Ul Hasnain on 05/07/2021.
//

import UIKit
import FirebaseMessaging

enum Storyboard: String {
    case foodie = "Foodies"
    case chef = "Chef"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(Class _viewControllerClass: T.Type) -> T {
        let  storboardID = (_viewControllerClass as UIViewController.Type).storyboardID
        return self.instance.instantiateViewController(withIdentifier: storboardID) as! T
    }
}

enum type {
    case tblView
    case collView
}
enum pinType {
    case allPins
    case idPin
}
enum SearchType {
    case partial
    case final
}

enum messagesCategory: CaseIterable {
    case messageRequest, messages
    
    var description: String {
        switch self {
        case .messageRequest:
            return "Message Request"
        default:
            return "Messages"
        }
    }
    
    
    static func numberOfSections() -> Int {
        return self.allCases.count
    }
    static func getMessageSection(_ section: Int) -> messagesCategory {
        return self.allCases[section]
    }
}
enum chefCategory: CaseIterable {
    case background, cuisine, expertise
    
    var description: String {
        switch self {
        case .background:
            return "Background"
        case .cuisine:
            return "Cuisine"
        default:
            return "Expertise"
        }
    }
    
    static func numberOfSections() -> Int {
        return self.allCases.count
    }
    static func getContactSection(_ section: Int) -> chefCategory {
        return self.allCases[section]
    }

}

struct CategoryName {
    let name : String
        
}

struct Constants {
    
    static let errorMsg = "Please try again."
    
    private init() {}
    // MARK: - appCredentials...
    struct appCredentials {
        private init() {}
        
        ///isSocialPlatfrom...
        static var isSocialPlatfrom: Bool {
            set { UserDefaults.standard.set(newValue, forKey: "isSocialPlatfrom")}
            get {
                if UserDefaults.standard.object(forKey: "isSocialPlatfrom") == nil {
                    UserDefaults.standard.set(false, forKey: "isSocialPlatfrom"); return false
                }
                return UserDefaults.standard.bool(forKey: "isSocialPlatfrom")
            }
        }
        
        static var password: String? {
            set { UserDefaults.standard.set(newValue, forKey: "password") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "password") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var imageURL: String? {
            set { UserDefaults.standard.set(newValue, forKey: "imageURL") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "imageURL") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var userUid: String? {
            set { UserDefaults.standard.set(newValue, forKey: "userUid") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "userUid") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var name: String? {
            set { UserDefaults.standard.set(newValue, forKey: "name") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "name") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var email: String? {
            set { UserDefaults.standard.set(newValue, forKey: "email") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "email") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        ///isFirstTimeLunch...
        static var isFirstTimeLunch: Bool {
            set { UserDefaults.standard.set(newValue, forKey: "isFirstTimeLunch")}
            get {
                if UserDefaults.standard.object(forKey: "isFirstTimeLunch") == nil {
                    UserDefaults.standard.set(false, forKey: "isFirstTimeLunch"); return false
                }
                return UserDefaults.standard.bool(forKey: "isFirstTimeLunch")
            }
        }
        
        ///fcmToken...
        static var fcmToken: String? {
            set { UserDefaults.standard.set(newValue, forKey: "fcmToken") }
            get {
                if let fcm = UserDefaults.standard.string(forKey: "fcmToken") {
                    print(fcm)
                    if fcm == "" { if let token = Messaging.messaging().fcmToken { return token }; return "" }
                    let fcmId = fcm
                    return fcmId
                } else { return "" }
            }
        }
    }
}

