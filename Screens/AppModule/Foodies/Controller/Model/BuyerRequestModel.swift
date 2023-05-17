//
//  BuyerRequestModel.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 15/02/2022.
//

import Foundation

class BuyerRequestModel {
     
    var id: String
    var description: String
    var category: String
    var timeAndDate: String
    var amount: Double
    var lat: Double
    var long: Double
    var address: String
    var mediaURl: String
    var accept: Bool
    var acceptedtBy: String
    var foodieID: String
    var startTime: String
    var endTime: String
    var selectedDate: String
    
    
    init(id: String, description: String, category: String, timeAndDate: String, amount: Double, lat: Double, long: Double, address: String, mediaURl: String, accept: Bool, acceptedtBy: String, foodieID: String, startTime: String, endTime: String, selectedDate: String) {
       self.id = id
       self.description = description
       self.category = category
       self.timeAndDate = timeAndDate
       self.amount = amount
       self.lat = lat
       self.long = long
       self.address = address
       self.mediaURl = mediaURl
       self.accept = accept
       self.acceptedtBy = acceptedtBy
       self.foodieID = foodieID
       self.startTime = startTime
       self.endTime = endTime
       self.selectedDate = selectedDate
   }
}
