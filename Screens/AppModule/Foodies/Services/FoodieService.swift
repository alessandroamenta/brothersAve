//
//  DataService.swift
//  WineOnWheel
//
//  Created by Syed Saood Ul Hasnain on 3/01/2021.
//  Copyright © 2019 Syed Saood Ul Hasnain All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import FirebaseStorage
import UIKit

class FoodieService{
    static let instance = FoodieService()
    
    let userReference = Firestore.firestore().collection("users")
    let orderReference = Firestore.firestore().collection("orders")
    let orderedLessonsRef = Firestore.firestore().collection("Orderedlessons")
    let requestReference = Firestore.firestore().collection("buyerRequest")
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var FoodieUser : FoodieUserModel!
    
    ///setCurrentUser...
    func setCurrentUser(foodie:FoodieUserModel){
        self.FoodieUser = foodie
    }
    
    ///emptyCurrentUser...
    func emptyCurrentUser(){
        FoodieUser = nil
    }
    
    ///updateFoodieUser...
    func updateFoodieUser(foodie:FoodieUserModel){
        userReference.document(foodie.id).setData([
            "id":foodie.id,
            "QBID":foodie.QBID,
            "name":foodie.name,
            "email":foodie.email,
            "role": foodie.role,
            "instagramLink":foodie.instagramLink,
            "tikTokLink": foodie.tikTokLink,
            "profilePic": foodie.profilePic,
            "address": foodie.address,
            "zipCode": foodie.zipCode,
            "long": foodie.long,
            "lat": foodie.lat,
            "fcmToken": foodie.fcmToken,
            "contactList": foodie.contactList,
            "customerId": foodie.customerId,
            "pendingClearence": foodie.pendingClearence,
            "notificationsAllowed": foodie.notificationsAllowed
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
            }
        }
    }
    
    ///getUserId...
    func getUserId()-> String {
        guard let uId = Auth.auth().currentUser?.uid else { return ""}
        return uId
    }
        
    ///checkIsUserAlreadyRegisteredOrNot...
    func checkIsUserAlreadyRegisteredOrNot(completion: @escaping (Bool)-> Void) {
        userReference.document(getUserId()).getDocument { doucument, error in
            if let _ = error { completion(false) }
            else { if doucument?.exists == true { completion(true) } else { completion(false) } }
        }
    }
    
    ///setUserData...
    func setUserData(userData: FoodieUserModel, completion: @escaping (APIBaseResult)-> Void) {
        userReference.document(getUserId()).setData(userData.dictionary) { error in
            if let _ = error { completion(.failure("error while updating Foodie data")) }
            else { completion(.success("Foodie data updated!")) }
        }
    }
    
    ///updateContactList...
    func updateContactList(userId: String, completion: @escaping (APIBaseResult)-> Void) {
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapShotMainUser, error in
            guard let UserData = snapShotMainUser?.data(), let User = ChefUserModel(dictionary: UserData) else { return }
            
            /// check user's contact list
            if User.contactList.contains(Auth.auth().currentUser?.uid ?? "") {
                ///getmyDocument
                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShotMainUser, error in
                    guard let myUserData = snapShotMainUser?.data(), let myUser = FoodieUserModel(dictionary: myUserData) else { return }
                    ///check my contact list
                    if myUser.contactList.contains(userId) {
                        completion(.success("This user already in my contact list"))
                    } else {
                        ///update my conatct list
                        var updateMyContactList = myUser.contactList
                        print("before update my contact list",updateMyContactList)
                        updateMyContactList.append(userId)
                        print("after update my contact list",updateMyContactList)
                        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").updateData(["contactList" : updateMyContactList]) { error in
                            if let _ = error { completion(.failure("Your contact List not updated")) }
                        }
                    }
                }
                
            } else {
                
                Firestore.firestore().collection("users").document(userId).getDocument { snapShotMainUser, error in
                    guard let chefData = snapShotMainUser?.data(), let chefUser = ChefUserModel(dictionary: chefData) else { return }
                    
                    ///check chef's contact list
                    if chefUser.contactList.contains(Auth.auth().currentUser?.uid ?? "") {
                        print("You're already added into chef's list")
                    } else {
                        ///update user's conatct list
                        var updateChefContactList = chefUser.contactList
                        print("before update chef's contact list",updateChefContactList)
                        updateChefContactList.append(Auth.auth().currentUser?.uid ?? "")
                        print("after update chef's contact list",updateChefContactList)
                        Firestore.firestore().collection("users").document(userId).updateData(["contactList" : updateChefContactList]) { error in
                            if error != nil { completion(.failure("chef contact List not updated")) }
                            else {
                                ///getmyDocument
                                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShotMainUser, error in
                                    guard let foodieData = snapShotMainUser?.data(), let foodie = FoodieUserModel(dictionary: foodieData) else { return }
                                    ///check my contact list
                                    if foodie.contactList.contains(userId) {
                                        completion(.success("This user already in my contact list"))
                                    } else {
                                        ///update my conatct list
                                        var updateMyContactList = foodie.contactList
                                        print("before update my contact list",updateMyContactList)
                                        updateMyContactList.append(userId)
                                        print("after update my contact list",updateMyContactList)
                                        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").updateData(["contactList" : updateMyContactList]) { error in
                                            if let _ = error { completion(.failure("Your contact List not updated")) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///getUserOfFoodieUser...
    func getUserOfFoodieUser(userID:String,handler: @escaping(_ success:Bool,_ foodie:FoodieUserModel?)->()){
        let userRef = userReference.document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let id = data["id"] as? String ?? "Not Found"
                let QBID = data["QBID"] as? UInt ?? 0
                let name = data["name"] as? String ?? "Not Found"
                let email = data["email"] as? String ?? "Not Found"
                let role = data["role"] as? String ?? "Not Found"
                let instagramLink = data["instagramLink"] as? String ?? "Not Found"
                let tikTokLink = data["tikTokLink"] as? String ?? "Not Found"
                let profilePic = data["profilePic"] as? String ?? "Not Found"
                let address = data["address"] as? String ?? "Not Found"
                let zipCode = data["zipCode"] as? String ?? "Not Found"
                let lat = data["lat"] as? Double ?? 0
                let long = data["long"] as? Double ?? 0
                let fcmToken = data["fcmToken"] as? String ?? "Not Found"
                let contactList = data["contactList"] as? [String] ?? [String]()
                let customerId = data["customerId"] as? String ?? ""
                let pendingClearence = data["pendingClearence"] as? Double ?? 0.0
                let notificationsAllowed = data["notificationsAllowed"] as? Bool ?? true
                
                let foodie = FoodieUserModel(id: id, QBID: QBID, name: name, email: email, role: role, instagramLink: instagramLink, tikTokLink: tikTokLink, profilePic: profilePic,address: address,zipCode: zipCode,fcmToken: fcmToken, lat: lat, long: long, contactList: contactList, customerId: customerId, pendingClearence: pendingClearence, notificationsAllowed: notificationsAllowed)
                handler(true,foodie)
                
            } else {
                handler(false,nil)
                print("Document does not exist")
            }
        }
    }
    
    ///checkOrderExist...
    func checkOrderExist(foodId:String,handler: @escaping(FirebaseAPIResult<Bool>)->()){
        
        Firestore.firestore().collection("orders").document(foodId).getDocument { snapshot, error in
            if error != nil {
                handler(.failure("this food/recipe does not exist in orders"))
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data();
                let foodId = data?["foodieId"] as? String ?? ""
                
                if foodId == Auth.auth().currentUser?.uid {
                    print("order already exist")
                    handler(.success(true))
                } else {
                    print("Order does not exist")
                    handler(.success(false))
                }
            }
        }
    }
    
    ///checkOrderLessonExist...
    func checkOrderLessonExist(lessonId:String,handler: @escaping(FirebaseAPIResult<Bool>)->()){
        
        Firestore.firestore().collection("Orderedlessons").document(lessonId).getDocument { snapshot, error in
            if error != nil {
                handler(.failure("this lesson does not exist in orders"))
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data();
                let foodId = data?["foodieId"] as? String ?? ""
                
                if foodId == Auth.auth().currentUser?.uid {
                    print("order already exist")
                    handler(.success(true))
                } else {
                    print("Order does not exist")
                    handler(.success(false))
                }
            }
        }
    }
    
    
    ///checkOrderLessonExist...
    func checkOrderRequestExist(requestId:String,handler: @escaping(FirebaseAPIResult<Bool>)->()){
        
        Firestore.firestore().collection("buyerRequestOrder").document(requestId).getDocument { snapshot, error in
            if error != nil {
                handler(.failure("this request does not exist in orders"))
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data();
                let foodId = data?["foodieId"] as? String ?? ""
                
                if foodId == Auth.auth().currentUser?.uid {
                    print("order already exist")
                    handler(.success(true))
                } else {
                    print("Order does not exist")
                    handler(.success(false))
                }
            }
        }
    }
    
    ///updateChefUser...
    func updateOrderedLessons(lesson: LessonModel, foodieId:String){
        orderedLessonsRef.document(lesson.id).setData([
            "id":lesson.id,
            "title":lesson.title,
            "description":lesson.description,
            "lat":lesson.lat,
            "long":lesson.long,
            "type":lesson.type,
            "location":lesson.location,
            "numberOfPeople":lesson.numberOfPeople,
            "duration":lesson.duration,
            "tools":lesson.tools,
            "link":lesson.link,
            "additionalNotes":lesson.additionalNotes,
            "chefId":lesson.chefId,
            "foodieId":foodieId,
            "image":lesson.image,
            "createdAt":lesson.createdAt,
            "cost":lesson.cost
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
            }
        }
    }
    
    ///getAllPostedLessons...
    func getAllOrderedLessons(completion: @escaping (APIResult<[LessonModel]>)-> Void) {
        let db = Firestore.firestore()
        db.collection("Orderedlessons").addSnapshotListener(includeMetadataChanges: true) { snapShot, error in
            if let _ = error { completion(.failure("Error getting ordered lessons")) }
            else {
                let orderedLessons = snapShot!.documents.compactMap({ LessonModel(dictionary: $0.data()) })
                completion(.success(orderedLessons))
            }
        }
    }
    
    ///deleteOrder...
    func deleteOrder(orderId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("orders").document(orderId).delete { error in
            if let _ = error { completion(.failure("error deleting order")) }
            else {  completion(.success("order cancelled successfully"))  }
        }
    }
    
    ///deleteRequest...
    func deleteRequest(orderId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("buyerRequest").document(orderId).delete { error in
            if let _ = error { completion(.failure("error deleting request")) }
            else {  completion(.success("request deleted successfully"))  }
        }
    }
    
    ///deleteOrderedLessons...
    func deleteOrderedLessons(lessonId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("Orderedlessons").document(lessonId).delete { error in
            if let _ = error { completion(.failure("error deleting order")) }
            else {  completion(.success("order cancelled successfully"))  }
        }
    }
    
    ///deleteCustomOrders...
    func deleteCustomOrders(requestId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("buyerRequestOrder").document(requestId).delete { error in
            if let _ = error { completion(.failure("error deleting order")) }
            else {  completion(.success("order cancelled successfully"))  }
        }
    }
    
    ///deleteFromAcceptedBuyerRequests...
    func deleteFromAcceptedBuyerRequests(requestId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("acceptedBuyerRequests").document(requestId).delete { error in
            if let _ = error { completion(.failure("error deleting request")) }
            else {  completion(.success("request deleted successfully"))  }
        }
    }
    
    ///updateProviderPendingClearence...
    func updatePendingClearenceOnCancel(providerUId: String, Amount: Double, completion: @escaping (APIBaseResult)-> Void) {

        //get pending clearence from selected user data...
        Firestore.firestore().collection("users").document(providerUId).getDocument { snapShot, error in
            if let _ = error {
                completion(.failure("error getting user's document")) }
            else {
                guard let data = snapShot!.data(), let userData = ChefUserModel(dictionary: data) else {
                    completion(.failure("error getting user's data")); return }
                let pendingClearence: Double = userData.pendingClearence - Amount

                //update chef's pending clearance...
                Firestore.firestore().collection("users").document(providerUId).updateData(["pendingClearence" : pendingClearence]) { error in
                    if let _ = error {
                        completion(.failure("error while updating user's pending clearence")) }
                    else {
                        
                        //get my pending clearance...
                        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
                            if let _ = error {
                                completion(.failure("error getting my document")) }
                            else {
                                guard let myData = snapShot!.data(), let myUser = FoodieUserModel(dictionary: myData) else {
                                    completion(.failure("error getting my data")); return }
                                let pendingClearence: Double = myUser.pendingClearence + Amount

                                //update my pending clearance...
                                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").updateData(["pendingClearence" : pendingClearence]) { error in
                                    if let _ = error {
                                        completion(.failure("error while updating my pending clearence")) }
                                    else {
                                        completion(.success("users updated succefully"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///getfoodieFood...
    func getfoodieFood(subCategory: String,search: String,handler: @escaping(_ success:Bool,_ cookings: [ChefCookingModel]?)->()){
        Firestore.firestore().collection("Cookings").whereField("category", in: [appdelegate.category]).whereField(subCategory, isEqualTo: search).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                return
            }
            var array:[ChefCookingModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let people = data["people"] as? String ?? "Not Found"
                    let difficulty = data["difficulty"] as? String ?? "Not Found"
                    let itemName = data["itemName"] as? String ?? "Not Found"
                    let pickUpLocation = data["pickUpLocation"] as? String ?? "Not Found"
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let cost = data["cost"] as? Double ?? 0
                    let pickUpDateAndTime = data["pickUpDateAndTime"] as? String ?? "Not Found"
                    let qunatity = data["qunatity"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let subCategory = data["subCategory"] as? String ?? "Not Found"
                    let status = data["status"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let category = data["category"] as? String ?? "Not Found"
                    let chefName = data["chefName"] as? String ?? "Not Found"
                    let chefId = data["chefId"] as? String ?? "Not Found"
                    let images = data["images"] as? [String] ?? []
                    let procedure = data["procedure"] as? [String] ?? []
                    let ingredients = data["ingredients"] as? [Ingredient] ?? []
                    
                    let cookings = ChefCookingModel(id: id, itemName: itemName, people: people, cost: cost, difficulty: difficulty, ingredients: ingredients, procedure: procedure ,images: images, pickUpLocation: pickUpLocation, lat: lat, long: long, startTime: startTime, endTime: endTime , selectedDate: selectedDate ,pickUpDateAndTime: pickUpDateAndTime, qunatity: qunatity, description: description, status: status, category: category, subCategory: subCategory,chefName: chefName,chefId: chefId)
                    if self.appdelegate.category == "food" {
                        let dateFormattor = DateFormatter()
                        dateFormattor.dateFormat = "dd/MM/yyyy"
                        // Today date convert into string
                        let todayDateString = dateFormattor.string(from: Date())
                        // Selected Date convert into Date Type
                        let selectStringDateToDate = dateFormattor.date(from: selectedDate)
                        // Today String type date convert into date
                        let todayStringDateToDate = dateFormattor.date(from: todayDateString)
                        
                        if selectStringDateToDate ?? Date() == todayStringDateToDate{
                            array.append(cookings)
                        }else if selectStringDateToDate  ?? Date() > todayStringDateToDate ?? Date() {
                            array.append(cookings)
                        }
                    }else{
                        array.append(cookings)
                        
                    }
                }
                handler(true,array)
            }
        }
    }
    
    ///getfoodieFoodAll...
    func getfoodieFoodAll(handler: @escaping(_ success:Bool,_ cookings: [ChefCookingModel]?)->()){
        Firestore.firestore().collection("Cookings").whereField("category", in: [appdelegate.category]).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                return
            }
            var array:[ChefCookingModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let difficulty = data["difficulty"] as? String ?? "Not Found"
                    let people = data["people"] as? String ?? "Not Found"
                    let itemName = data["itemName"] as? String ?? "Not Found"
                    let pickUpLocation = data["pickUpLocation"] as? String ?? "Not Found"
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let cost = data["cost"] as? Double ?? 0
                    let pickUpDateAndTime = data["pickUpDateAndTime"] as? String ?? "Not Found"
                    let qunatity = data["qunatity"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let subCategory = data["subCategory"] as? String ?? "Not Found"
                    let status = data["status"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let category = data["category"] as? String ?? "Not Found"
                    let chefName = data["chefName"] as? String ?? "Not Found"
                    let chefId = data["chefId"] as? String ?? "Not Found"
                    let images = data["images"] as? [String] ?? []
                    let procedure = data["procedure"] as? [String] ?? []
                    let ingredients = data["ingredients"] as? [Ingredient] ?? []
                    
                    let cookings = ChefCookingModel(id: id, itemName: itemName, people: people, cost: cost, difficulty: difficulty, ingredients: ingredients, procedure: procedure ,images: images, pickUpLocation: pickUpLocation, lat: lat, long: long, startTime: startTime, endTime: endTime , selectedDate: selectedDate ,pickUpDateAndTime: pickUpDateAndTime, qunatity: qunatity, description: description, status: status, category: category, subCategory: subCategory,chefName: chefName,chefId: chefId)
                    if self.appdelegate.category == "food" {
                        let dateFormattor = DateFormatter()
                        dateFormattor.dateFormat = "dd/MM/yyyy"
                        // Today date convert into string
                        let todayDateString = dateFormattor.string(from: Date())
                        // Selected Date convert into Date Type
                        let selectStringDateToDate = dateFormattor.date(from: selectedDate)
                        // Today String type date convert into date
                        let todayStringDateToDate = dateFormattor.date(from: todayDateString)
                        
                        if selectStringDateToDate ?? Date() == todayStringDateToDate{
                            array.append(cookings)
                        }else if selectStringDateToDate  ?? Date() > todayStringDateToDate ?? Date() {
                            array.append(cookings)
                        }
                    }else{
                        array.append(cookings)
                        
                    }
                }
                handler(true,array)
            }
        }
    }
    
    ///createOrder...
    func createOrder(cook:ChefCookingModel,foodieId: String){
        orderReference.document(cook.id).setData([
            "id":cook.id,
            "itemName":cook.itemName,
            "images":cook.images,
            "pickUpLocation": cook.pickUpLocation,
            "pickUpDateAndTime":cook.pickUpDateAndTime,
            "qunatity": cook.qunatity,
            "description": cook.description,
            "status": cook.status,
            "category": cook.category,
            "long": cook.long,
            "lat": cook.lat,
            "subCategory": cook.subCategory,
            "chefName": cook.chefName,
            "startTime":cook.startTime,
            "endTime": cook.endTime,
            "selectedDate": cook.selectedDate,
            "chefId": cook.chefId,
            "foodieId": foodieId,
            "createdAt": FieldValue.serverTimestamp(),
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
                print("Order created successfully")
            }
        }
    }
    
    ///savebuyerRequest...
    func savebuyerRequest(request:BuyerRequestModel){
        requestReference.document(request.id).setData([
            "id":request.id,
            "description":request.description,
            "category":request.category,
            "timeAndDate": request.timeAndDate,
            "lat":request.lat,
            "long": request.long,
            "mediaURl": request.mediaURl,
            "accept": request.accept,
            "acceptedtBy": request.acceptedtBy,
            "amount": request.amount,
            "startTime": request.startTime,
            "endTime": request.endTime,
            "foodieId":request.foodieID,
            "address": request.address,
            "createdAt": FieldValue.serverTimestamp(),
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error creating request: \(err)")
            } else {
            }
        }
    }
    
    ///createBuyerRequestOrder...
    func createBuyerRequestOrder(request:BuyerRequestModel, acceptedBy: String){
        Firestore.firestore().collection("buyerRequestOrder").document(request.id).setData([
            "id":request.id,
            "description":request.description,
            "category":request.category,
            "timeAndDate": request.timeAndDate,
            "lat":request.lat,
            "long": request.long,   
            "mediaURl": request.mediaURl,
            "accept": request.accept,
            "acceptedtBy": acceptedBy,
            "amount": request.amount,
            "foodieId":request.foodieID,
            "startTime": request.startTime,
            "endTime": request.endTime,
            "address": request.address,
            "createdAt": FieldValue.serverTimestamp(),
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error creating request order: \(err)")
            } else {
                self.removeRequestAfterAccepting(orderId: request.id)
            }
        }
    }
    
    ///deleteOrder...
    func removeRequestAfterAccepting(orderId: String){
        FoodieService.instance.deleteRequest(orderId: orderId) { resultent in
            switch resultent {
            case .success(let response):
                print(response)
                print(response)
            case .failure(let error):
               print(error)
            }
        }
    }
    
    ///removeFromAcceptedRequests...
    func removeFromAcceptedRequests(requestId: String){
        FoodieService.instance.deleteFromAcceptedBuyerRequests(requestId: requestId) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    ///createBuyerRequestOrder...
    func createAcceptedBuyerRequests(request:BuyerRequestModel,chefID: String, completion: @escaping (APIResult<String>)-> Void){
        Firestore.firestore().collection("acceptedBuyerRequests").document(request.id).setData([
            "id":request.id,
            "description":request.description,
            "category":request.category,
            "timeAndDate": request.timeAndDate,
            "amount": request.amount,
            "lat":request.lat,
            "long": request.long,
            "address": request.address,
            "mediaURl": request.mediaURl,
            "accept": request.accept,
            "acceptedtBy": chefID,
            "foodieId":request.foodieID,
            "startTime":request.startTime,
            "endTime":request.endTime,
            "createdAt": FieldValue.serverTimestamp(),
        ], merge: true) { (err) in
            if let err = err {
                completion(.failure("Error accepting request"))
                debugPrint(": \(err)")
            } else {
                completion(.success("Request accepted successfully"))
            }
        }
    }
    
    ///getFoodieOrder...
    func getFoodieOrder(fieldName:String,handler: @escaping(_ success:Bool,_ cookings: [ChefCookingModel]?)->()){
        Firestore.firestore().collection("orders").whereField(fieldName, in: [Auth.auth().currentUser?.uid ?? ""]).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                handler(false,nil)
                return
            }
            var array:[ChefCookingModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let people = data["people"] as? String ?? "Not Found"
                    let difficulty = data["difficulty"] as? String ?? "Not Found"
                    let itemName = data["itemName"] as? String ?? "Not Found"
                    
                    let pickUpLocation = data["pickUpLocation"] as? String ?? "Not Found"
                    let cost = data["cost"] as? Double ?? 0
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let pickUpDateAndTime = data["pickUpDateAndTime"] as? String ?? "Not Found"
                    let qunatity = data["qunatity"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let subCategory = data["subCategory"] as? String ?? "Not Found"
                    let status = data["status"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let category = data["category"] as? String ?? "Not Found"
                    let chefName = data["chefName"] as? String ?? "Not Found"
                    let chefId = data["chefId"] as? String ?? "Not Found"
                    // let chefId = data["foodieId"] as? String ?? "Not Found"
                    let images = data["images"] as? [String] ?? []
                    let procedure = data["procedure"] as? [String] ?? []
                    let ingredients = data["ingredients"] as? [Ingredient] ?? []
                    
                    let cookings = ChefCookingModel(id: id, itemName: itemName, people: people, cost: cost, difficulty: difficulty, ingredients: ingredients, procedure: procedure ,images: images, pickUpLocation: pickUpLocation, lat: lat, long: long, startTime: startTime, endTime: endTime , selectedDate: selectedDate ,pickUpDateAndTime: pickUpDateAndTime, qunatity: qunatity, description: description, status: status, category: category, subCategory: subCategory,chefName: chefName,chefId: chefId)
                    array.append(cookings)
                }
                handler(true,array)
            }
        }
    }
    
    ///getFoodieCustomRequestOrders...
    func getFoodieCustomRequestOrders(fieldName:String,handler: @escaping(_ success:Bool,_ request: [BuyerRequestModel]?)->()){
        Firestore.firestore().collection("buyerRequestOrder").whereField(fieldName, in: [Auth.auth().currentUser?.uid ?? ""]).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                handler(false,nil)
                return
            }
            var array:[BuyerRequestModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let category = data["category"] as? String ?? "Not Found"
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let timeAndDate = data["timeAndDate"] as? String ?? "Not Found"
                    let amount = data["amount"] as? Double ?? 0.0
                    let address = data["address"] as? String ?? "Not Found"
                    let mediaURl = data["mediaURl"] as? String ?? "Not Found"
                    let foodieID = data["foodieId"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let accept = data["accept"] as? Bool ?? false
                    let request = BuyerRequestModel(id: id, description: description, category: category, timeAndDate: timeAndDate, amount: amount, lat: lat, long: long, address: address, mediaURl: mediaURl, accept: accept, acceptedtBy: "", foodieID: foodieID,startTime: startTime,endTime: endTime,selectedDate: selectedDate)
                    array.append(request)
                }
                handler(true,array)
            }else{
                handler(true,nil)
            }
        }
    }
    
    ///getFoodieCustomRequestOrders...
    func getFoodieAcceptedRequests(fieldName:String,handler: @escaping(_ success:Bool,_ request: [BuyerRequestModel]?)->()){
        Firestore.firestore().collection("acceptedBuyerRequests").whereField(fieldName, in: [Auth.auth().currentUser?.uid ?? ""]).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                handler(false,nil)
                return
            }
            var array:[BuyerRequestModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let category = data["category"] as? String ?? "Not Found"
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let timeAndDate = data["timeAndDate"] as? String ?? "Not Found"
                    let amount = data["amount"] as? Double ?? 0.0
                    let address = data["address"] as? String ?? "Not Found"
                    let mediaURl = data["mediaURl"] as? String ?? "Not Found"
                    let foodieID = data["foodieId"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let accept = data["accept"] as? Bool ?? false
                    let request = BuyerRequestModel(id: id, description: description, category: category, timeAndDate: timeAndDate, amount: amount, lat: lat, long: long, address: address, mediaURl: mediaURl, accept: accept, acceptedtBy: "", foodieID: foodieID,startTime: startTime,endTime: endTime,selectedDate: selectedDate)
                    array.append(request)
                }
                handler(true,array)
            }else{
                handler(true,nil)
            }
        }
    }
    
    ///getFoodieCustomRequestOrders...
    func getFoodieLessonOrders(fieldName:String,handler: @escaping(_ success:Bool,_ request: [LessonModel]?)->()){
        Firestore.firestore().collection("Orderedlessons").whereField(fieldName, in: [Auth.auth().currentUser?.uid ?? ""]).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                handler(false,nil)
                return
            }
            var array:[LessonModel] = []
            if snapshot.count >= 0 {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? "Not Found"
                    let title = data["title"] as? String ?? "Not Found"
                    let description = data["description"] as? String ?? "Not Found"
                    let lat = data["lat"] as? Double ?? 0
                    let long = data["long"] as? Double ?? 0
                    let type = data["type"] as? String ?? "Not Found"
                    let location = data["location"] as? String ?? "Not Found"
                    let numberOfPeople = data["numberOfPeople"] as? Int ?? 0
                    let duration = data["duration"] as? Int ?? 0
                    let tools = data["tools"] as? String ?? "Not Found"
                    let link = data["link"] as? String ?? "Not Found"
                    let additionalNotes = data["additionalNotes"] as? String ?? "Not Found"
                    let chefId = data["chefId"] as? String ?? "Not Found"
                    let image = data["image"] as? String ?? ""
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
                    let cost = data["cost"] as? Double ?? 0.0
                    
                    let lesson = LessonModel(id: id, title: title, description: description, duration: duration, tools: tools, type: type, location: location, lat: lat, long: long, numberOfPeople: numberOfPeople, link: link, additionalNotes: additionalNotes, chefId: chefId, image: image, createdAt: createdAt, cost: cost)
                    array.append(lesson)
                }
                handler(true,array)
            }else{
                handler(true,array)
            }
        }
    }
    
    ///uploadPIcture...
    func uploadPIcture(collectionName:String,image:UIImage,handler :@escaping(_ success:Bool,_ picUrl:String)->()){
        var downloadLink = ""
        let imageData = image.jpegData(compressionQuality: 0.7)
        let storageRef = Storage.storage().reference().child(collectionName).child(("\(UUID().uuidString).jpg"))
        _ = storageRef.putData(imageData!, metadata: nil) { (metaData, error) in
            print("upload task finished")
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil
                {
                    print(error!)
                    handler(false, "")
                }
                else
                {
                    downloadLink = (url?.absoluteString) ?? ""
                    handler(true,downloadLink)
                }
            })
        }
    }
    
    ///uploadVideos...
    func uploadVideos(videoURL:URL,handler :@escaping(_ success:Bool,_ videoUrl:String)-> Void){
        var downloadLink = ""
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        if let videoData = NSData(contentsOf: videoURL) as Data? {
            let storageRef = Storage.storage().reference().child("PartyMedia").child(("\(UUID().uuidString)PartyMediaVideo.mp4"))
            _ = storageRef.putData(videoData, metadata: metadata) { (metaData, err) in
                print("upload task finished")
                if let err = err {
                    print("Failed to upload movie:", err)
                    handler(false,downloadLink)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Failed to get download url:", err)
                        handler(false,downloadLink)
                        return
                        
                    }
                    else
                    {
                        downloadLink = (url?.absoluteString) ?? ""
                        handler(true,downloadLink)
                    }
                })
            }
        }
    }
}
