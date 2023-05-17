//
//  FoodieUserModel.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 14/10/2021.
//

import Foundation

struct FoodieUserModel {
    
    var id                   : String
    var QBID                 : UInt
    var name                 : String
    var email                : String
    var role                 : String
    var instagramLink        : String
    var tikTokLink           : String
    var profilePic           : String
    var address              : String
    var zipCode              : String
    var fcmToken             : String
    var lat                  : Double
    var long                 : Double
    var contactList          : [String]
    var customerId           : String
    var pendingClearence     : Double
    var notificationsAllowed : Bool
    
    var dictionary : [String : Any] {
        return [
        
            "id"                   : id,
            "QBID"                 : QBID,
            "name"                 : name,
            "email"                : email,
            "role"                 : role,
            "instagramLink"        : instagramLink,
            "tikTokLink"           : tikTokLink,
            "profilePic"           : profilePic,
            "address"              : address,
            "zipCode"              : zipCode,
            "fcmToken"             : fcmToken,
            "lat"                  : lat,
            "long"                 : long,
            "contactList"          : contactList,
            "customerId"           : customerId,
            "pendingClearence"     : pendingClearence,
            "notificationsAllowed" : notificationsAllowed
            
        ]
    }
}

extension FoodieUserModel : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        
        let id = dictionary["id"] as? String
        let QBID = dictionary["QBID"] as? UInt
        let name = dictionary["name"] as? String
        let email = dictionary["email"] as? String
        let role = dictionary["role"] as? String
        let instagramLink = dictionary["instagramLink"] as? String
        let tikTokLink = dictionary["tikTokLink"] as? String
        let profilePic = dictionary["profilePic"] as? String
        let address = dictionary["address"] as? String
        let zipCode = dictionary["zipCode"] as? String
        let fcmToken = dictionary["fcmToken"] as? String
        let lat = dictionary["lat"] as? Double
        let long = dictionary["long"] as? Double
        let contactList = dictionary["contactList"] as? [String]
        let customerId = dictionary["customerId"] as? String
        let pendingClearence = dictionary["pendingClearence"] as? Double
        let notificationsAllowed = dictionary["notificationsAllowed"] as? Bool
        
        self.init(id: id ?? "",QBID: QBID ?? 0, name: name ?? "", email: email ?? "", role: role ?? "", instagramLink: instagramLink ?? "", tikTokLink: tikTokLink ?? "", profilePic: profilePic ?? "", address: address ?? "", zipCode: zipCode ?? "", fcmToken: fcmToken ?? "", lat: lat ?? 0.0, long: long ?? 0.0, contactList: contactList ?? [String](), customerId: customerId ?? "", pendingClearence: pendingClearence ?? 0.0, notificationsAllowed: notificationsAllowed ?? true)
    }
}
