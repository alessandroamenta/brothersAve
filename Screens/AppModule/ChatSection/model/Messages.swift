//
//  Messages.swift
//  Food App
//
//  Created by HF on 05/12/2022.
//

import Foundation

struct MessagesModel: Hashable {
    
    var senderId     : UInt
    var receiverId   : UInt
    var message      : String
    var imageURL     : String?
    var sentTimeDate : String
    
}

struct RecentMessagesModel {
    
    var userName       : String
    var userImage      : String
    var latestMessage  : String
    var dateSent       : String
    var QBID           : UInt
    
    var dictionary: [String: Any] {
        return [
            "userName"       : userName,
            "userImage"      : userImage,
            "latestMessage"  : latestMessage,
            "dateSent"       : dateSent,
            "QBID"           : QBID

        ]
    }
}

extension RecentMessagesModel : DocumentSerializable {
    
    init?(dictionary: [String : Any]) {
        let userName = dictionary["userName"] as? String
        let userImage = dictionary["userImage"] as? String
        let latestMessage = dictionary["latestMessage"] as? String
        let dateSent = dictionary["dateSent"] as? String
        let QBID = dictionary["QBID"] as? UInt
         
        self.init(userName: userName ?? "", userImage: userImage ?? "", latestMessage: latestMessage ?? "", dateSent: dateSent ?? "", QBID: QBID ?? 0)
    }
}
