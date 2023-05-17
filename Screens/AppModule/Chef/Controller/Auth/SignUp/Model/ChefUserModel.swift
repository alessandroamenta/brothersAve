//
//  ChefUserModel.swift
//  Food App
//
//  Created by Chirp Technologies on 14/10/2021.
//

import UIKit
import FirebaseAuth

struct ChefUserModel {
    
    var id                 : String
    var QBID               : UInt
    var name               : String
    var email              : String
    var role               : String
    var instagramLink      : String
    var tikTokLink         : String
    var profilePic         : String
    var address            : String
    var zipcode            : String
    var courses            : [String]
    var isRequirement      : Bool
    var achevements        : [String]
    var background         : [String]
    var cusine             : [String]
    var experties          : [String]
    var buyerRequests      : [String]
    var lat                : Double
    var long               : Double
    var journey            : String
    var fcmToken           : String
    var cookingIds         : [String]
    var contactList        : [String]
    var customerId         : String
    var pendingClearence   : Double
    var connectedAccountId : String
    var isAccountVarified  : Bool
    var rating             : Double
    
    var dictionary: [String: Any] {
        return [
            "id"                    : id,
            "QBID"                  : QBID,
            "name"                  : name,
            "email"                 : email,
            "role"                  : role,
            "instagramLink"         : instagramLink,
            "tikTokLink"            : tikTokLink,
            "profilePic"            : profilePic,
            "address"               : address,
            "zipcode"               : zipcode,
            "courses"               : courses,
            "isRequirement"         : isRequirement,
            "achevements"           : achevements,
            "background"            : background,
            "cusine"                : cusine,
            "experties"             : experties,
            "buyerRequests"         : buyerRequests,
            "lat"                   : lat,
            "long"                  : long,
            "journey"               : journey,
            "fcmToken"              : fcmToken,
            "cookingIds"            : cookingIds,
            "contactList"           : contactList,
            "customerId"            : customerId,
            "pendingClearence"      : pendingClearence,
            "connectedAccountId"    : connectedAccountId,
            "isAccountVarified"     : isAccountVarified,
            "rating"                : rating
    
        ]
    }
}
 
extension ChefUserModel : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        
        let id                 = dictionary["id"]                 as? String
        let QBID               = dictionary["QBID"]               as? UInt
        let name               = dictionary["name"]               as? String
        let email              = dictionary["email"]              as? String
        let role               = dictionary["role"]               as? String
        let instagramLink      = dictionary["instagramLink"]      as? String
        let tikTokLink         = dictionary["tikTokLink"]         as? String
        let profilePic         = dictionary["profilePic"]         as? String
        let address            = dictionary["address"]            as? String
        let zipcode            = dictionary["zipcode"]            as? String
        let courses            = dictionary["courses"]            as? [String]
        let isRequirement      = dictionary["isRequirement"]      as? Bool
        let achevements        = dictionary["achevements"]        as? [String]
        let background         = dictionary["background"]         as? [String]
        let cusine             = dictionary["cusine"]             as? [String]
        let experties          = dictionary["experties"]          as? [String]
        let buyerRequests      = dictionary["buyerRequests"]      as? [String]
        let lat                = dictionary["lat"]                as? Double
        let long               = dictionary["long"]               as? Double
        let journey            = dictionary["journey"]            as? String
        let fcmToken           = dictionary["fcmToken"]           as? String
        let cookingIds         = dictionary["cookingIds"]         as? [String]
        let contactList        = dictionary["contactList"]        as? [String]
        let customerId         = dictionary["customerId"]         as? String
        let pendingClearence   = dictionary["pendingClearence"]   as? Double
        let connectedAccountId = dictionary["connectedAccountId"] as? String
        let isAccountVarified  = dictionary["isAccountVarified"]  as? Bool
        let rating             = dictionary["rating"]             as? Double
        
        self.init(id: id ?? "" ,QBID: QBID ?? 0, name: name ?? "", email: email ?? "", role: role ?? "", instagramLink: instagramLink ?? "", tikTokLink: tikTokLink ?? "", profilePic: profilePic ?? "", address: address ?? "", zipcode: zipcode ?? "", courses: courses ?? [String](), isRequirement: isRequirement ?? true, achevements: achevements ?? [String](), background: background ?? [String](), cusine: cusine ?? [String](), experties: experties ?? [String](), buyerRequests: buyerRequests ?? [String](), lat: lat ?? 0.0, long: long ?? 0.0, journey: journey ?? "", fcmToken: fcmToken ?? "", cookingIds: cookingIds ?? [String](), contactList: contactList ?? [String](), customerId: customerId ?? "", pendingClearence: pendingClearence ?? 0.0, connectedAccountId: connectedAccountId ?? "", isAccountVarified: isAccountVarified ?? false, rating: rating ?? 0.0)
    }
}

struct appCredentials {
    private init() {}
    
    ///withDrawAccountId...
      static var connectedAccountId: String? {
          set { UserDefaults.standard.set(newValue, forKey: "connectedAccountId") }
          get {
              if let value = UserDefaults.standard.string(forKey: "connectedAccountId") {
                  if value == "" { return "" }
                  let data = value; return data
              } else { return "" }
          }
      }
        
    ///customerStripeId...
    static var customerStripeId: String? {
        set { UserDefaults.standard.set(newValue, forKey: "customerStripeId") }
        get {
            if let value = UserDefaults.standard.string(forKey: "customerStripeId") {
                if value == "" { return "" }
                let data = value; return data
            } else { return "" }
        }
    }
    
    ///isSocialPlatfrom...
    static var isComingfromOrders: Bool {
        set { UserDefaults.standard.set(newValue, forKey: "isComingfromOrders")}
        get {
            if UserDefaults.standard.object(forKey: "isComingfromOrders") == nil {
                UserDefaults.standard.set(true, forKey: "isComingfromOrders"); return true
            }
            return UserDefaults.standard.bool(forKey: "isComingfromOrders")
        }
    }
    
    ///isComingfromLessons...
    static var isComingfromLessons: Bool {
        set { UserDefaults.standard.set(newValue, forKey: "isComingfromLessons")}
        get {
            if UserDefaults.standard.object(forKey: "isComingfromLessons") == nil {
                UserDefaults.standard.set(true, forKey: "isComingfromLessons"); return true
            }
            return UserDefaults.standard.bool(forKey: "isComingfromLessons")
        }
    }
    
    ///isComingfromRequests...
    static var isComingfromRequests: Bool {
        set { UserDefaults.standard.set(newValue, forKey: "isComingfromRequests")}
        get {
            if UserDefaults.standard.object(forKey: "isComingfromRequests") == nil {
                UserDefaults.standard.set(true, forKey: "isComingfromRequests"); return true
            }
            return UserDefaults.standard.bool(forKey: "isComingfromRequests")
        }
    }
    
    ///isComingfromLessons...
    static var isComingfromFoodie: Bool {
        set { UserDefaults.standard.set(newValue, forKey: "isComingfromFoodie")}
        get {
            if UserDefaults.standard.object(forKey: "isComingfromFoodie") == nil {
                UserDefaults.standard.set(false, forKey: "isComingfromFoodie"); return true
            }
            return UserDefaults.standard.bool(forKey: "isComingfromFoodie")
        }
    }
    
    ///isComingfromFood...
    static var isComingfromFood: Bool {
        set { UserDefaults.standard.set(newValue, forKey: "isComingfromFood")}
        get {
            if UserDefaults.standard.object(forKey: "isComingfromFood") == nil {
                UserDefaults.standard.set(true, forKey: "isComingfromFood"); return true
            }
            return UserDefaults.standard.bool(forKey: "isComingfromFood")
        }
    }
    
    ///pendingClearence...
    static var pendingClearence: Double? {
        set {UserDefaults.standard.set(newValue, forKey: "pendingClearence")}
        get {
            let points = UserDefaults.standard.double(forKey: "pendingClearence")
            if points == 0 { return 0 }
            let pointsStr = points
            return pointsStr
        }
    }
    
    ///currentOrder...
    static var currentOrder: String? {
        set { UserDefaults.standard.set(newValue, forKey: "currentOrder") }
        get {
            if let value = UserDefaults.standard.string(forKey: "currentOrder") {
                if value == "" { return "0" }
                let data = value; return data
            } else { return "0" }
        }
    }
    
    ///pappal...
    static var paypal: String? {
        set { UserDefaults.standard.set(newValue, forKey: "paypal") }
        get {
            if let value = UserDefaults.standard.string(forKey: "paypal") {
                if value == "" { return "" }
                let data = value; return data
            } else { return "" }
        }
    }
    
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
    
    ///name...
    static var name: String? {
        set { UserDefaults.standard.set(newValue, forKey: "userName") }
        get {
            if let getUid = UserDefaults.standard.string(forKey: "userName") {
                if getUid == "" { return "" }
                let uid = getUid; return uid
            } else { return "" }
        }
    }
    
    ///uid...
    static var uid: String? {
        set { UserDefaults.standard.set(newValue, forKey: "uid") }
        get {
            if let getUid = UserDefaults.standard.string(forKey: "uid") {
                if getUid == "" { return Auth.auth().currentUser?.uid ?? "" }
                let uid = getUid; return uid
            } else { return Auth.auth().currentUser?.uid ?? "" }
        }
    }
    
    ///chefId...
    static var chefId: String? {
        set { UserDefaults.standard.set(newValue, forKey: "chefId") }
        get {
            if let getUid = UserDefaults.standard.string(forKey: "chefId") {
                if getUid == "" { return "" }
                let chefId = getUid; return chefId
            } else { return "" }
        }
    }
    
    ///email...
    static var email: String? {
        set { UserDefaults.standard.set(newValue, forKey: "userEmail") }
        get {
            if let getUid = UserDefaults.standard.string(forKey: "userEmail") {
                if getUid == "" { return "" }
                let uid = getUid; return uid
            } else { return "" }
        }
    }
    
}
