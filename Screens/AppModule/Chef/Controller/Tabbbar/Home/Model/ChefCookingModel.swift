//
//  ChefCookingModel.swift
//  Food App
//
//  Created by Chirp Technologies on 18/10/2021.
//

import UIKit

struct ChefCookingModel {
    
    var id: String
    var itemName: String
    var people: String
    var cost: Double
    var difficulty: String
    let ingredients: [Ingredient]?
    var procedure: [String]
    var images : [String]
    var pickUpLocation: String
    var lat: Double
    var long: Double
    var startTime: String
    var endTime: String
    var selectedDate: String
    var pickUpDateAndTime: String
    var qunatity: String
    var description: String
    var status : String
    var category: String
    var subCategory: String
    var chefName: String
    var chefId: String
    
    var dictionary: [String: Any] {
        return [
            "id"                 : id,
            "itemName"           : itemName,
            "cost"               : cost,
            "difficulty"         : difficulty,
            "ingredients"        : ingredients,
            "procedure"          : procedure,
            "images"             : images,
            "pickUpLocation"     : pickUpLocation,
            "lat"                : lat,
            "long"               : long,
            "startTime"          : startTime,
            "endTime"            : endTime,
            "selectedDate"       : selectedDate,
            "pickUpDateAndTime"  : pickUpDateAndTime,
            "qunatity"           : qunatity,
            "description"        : description,
            "status"             : status,
            "category"           : category,
            "subCategory"        : subCategory,
            "pickUpDateAndTime"  : pickUpDateAndTime,
            "chefName"           : chefName,
            "chefId"             : chefId
    
        ]
    }
}

extension ChefCookingModel : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        
            let id = dictionary["id"] as? String ?? ""
            let itemName = dictionary["itemName"] as? String ?? ""
            let people = dictionary["people"] as? String ?? ""
            let cost = dictionary["cost"] as? Double ?? 0
            let difficulty = dictionary["difficulty"] as? String ?? ""
            let ingredients = dictionary["ingredients"] as? [Ingredient] ?? []
            let procedure = dictionary["procedure"] as? [String] ?? []
            let images = dictionary["images"] as? [String] ?? []
            let pickUpLocation = dictionary["pickUpLocation"] as? String ?? ""
            let lat = dictionary["lat"] as? Double ?? 0
            let long = dictionary["long"] as? Double ?? 0
            let startTime = dictionary["startTime"] as? String ?? ""
            let endTime = dictionary["endTime"] as? String ?? ""
            let selectedDate = dictionary["selectedDate"] as? String ?? ""
            let pickUpDateAndTime = dictionary["pickUpDateAndTime"] as? String ?? ""
            let qunatity = dictionary["qunatity"] as? String ?? ""
            let description = dictionary["description"] as? String ?? ""
            let status = dictionary["status"] as? String ?? ""
            let category = dictionary["category"] as? String ?? ""
            let subCategory = dictionary["subCategory"] as? String ?? ""
            let chefName = dictionary["chefName"] as? String ?? ""
            let chefId = dictionary["chefId"] as? String ?? ""
            
        self.init(id: id, itemName: itemName, people: people, cost: cost, difficulty: difficulty, ingredients: ingredients, procedure: procedure, images: images, pickUpLocation: pickUpLocation, lat: lat, long: long, startTime: startTime, endTime: endTime, selectedDate: selectedDate, pickUpDateAndTime: pickUpDateAndTime, qunatity: qunatity, description: description, status: status, category: category, subCategory: subCategory, chefName: chefName, chefId: chefId)
            
        }
    
}

struct Ingredient: Codable {
    var id, name, unit: String
    
    var dictionary: [String: Any] {
        [
            "id"   : id,
            "name" : name,
            "unit" : unit
        ]
    }
}

extension Ingredient : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        let id = dictionary["id"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let unit = dictionary["unit"] as? String ?? ""
        
        self.init(id: id, name: name, unit: unit)
    }
}
