//
//  PushNotificationSender.swift
//  Wind Searched
//
//  Created by Hamza Shahbaz on 30/04/2021.
//  Copyright © 2021 Hamza Shahbaz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String,unread:Int,image: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = [
            
            "to" : token,
                "content_available": true,
                "mutable_content": true,
                "category": "CustomSamplePush",
                
                   "notification" : [
                        "title" : title,
                        "body" : body,
                        "sound" : "notification_sound"
                   ],
                   "data": [
                    "userID" : Auth.auth().currentUser?.uid ?? "",
                       "urlImageString":image
                   ]
           ]
     
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAABbFkORI:APA91bE6Jkp3PxR28DtF_KyLD-9jZe8lxS0JyKKgfTECuLT1jpLOCDbKQoAOeuMoX5lCe8EqxV7rkjF_VnIm_XkBuLoU0E3eiPHWlEh_AhpCxveqKz_nv5k3oLDOo-r25MInsFTkrB4p", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
