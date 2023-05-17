//
//  LessonModel.swift
//  Food App
//
//  Created by Chirp Technologies on 28/02/2022.
//

import UIKit
import FirebaseFirestore

struct LessonModel {
    
    var id              : String
    var title           : String
    var description     : String
    var duration        : Int
    var tools           : String
    var type            : String
    var location        : String
    var lat             : Double
    var long            : Double
    var numberOfPeople  : Int
    var link            : String
    var additionalNotes : String
    var chefId          : String
    var image           : String
    var createdAt       : Timestamp
    var cost            : Double
    
    var dictionary: [String: Any] {
        return [
            "id"               : id,
            "title"            : title,
            "description"      : description,
            "duration"         : duration,
            "tools"            : tools,
            "type"             : type,
            "location"         : location,
            "lat"              : lat,
            "long"             : long,
            "numberOfPeople"   : numberOfPeople,
            "link"             : link,
            "additionalNotes"  : additionalNotes,
            "chefId"           : chefId,
            "image"            : image,
            "createdAt"        : createdAt,
            "cost"             : cost
    
        ]
    }
}

extension LessonModel : DocumentSerializable {
    init?(dictionary : [String : Any]) {
        
        let id = dictionary["id"] as? String
        let title = dictionary["title"] as? String
        let description = dictionary["description"] as? String
        let duration = dictionary["duration"] as? Int
        let tools = dictionary["tools"] as? String
        let type = dictionary["type"] as? String
        let location = dictionary["location"] as? String
        let lat = dictionary["lat"] as? Double
        let long = dictionary["long"] as? Double
        let numberOfPeople = dictionary["numberOfPeople"] as? Int
        let link = dictionary["link"] as? String
        let additionalNotes = dictionary["additionalNotes"] as? String
        let chefId = dictionary["chefId"] as? String
        let image = dictionary["image"] as? String
        let createdAt = dictionary["createdAt"] as? Timestamp
        let cost = dictionary["cost"] as? Double
        
        self.init(id: id ?? "", title: title ?? "", description: description ?? "", duration: duration ?? 0, tools: tools ?? "", type: type ?? "", location: location ?? "", lat: lat ?? 0.0, long: long ?? 0.0, numberOfPeople: numberOfPeople ?? 0, link: link ?? "", additionalNotes: additionalNotes ?? "", chefId: chefId ?? "", image: image ?? "", createdAt: createdAt ?? Timestamp(date: Date()), cost: cost ?? 0.0)
    }
}
