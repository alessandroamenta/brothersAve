//
//  ChefService.swift
//  Food App
//
//  Created by Chirp Technologies on 14/10/2021.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ChefService {
    
    static let instance = ChefService()

    let userReference = Firestore.firestore().collection("users")
    let chefcookings = Firestore.firestore().collection("Cookings")
    let lessonReference = Firestore.firestore().collection("lessons")
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var chefUser : ChefUserModel!
    var ingParams : [[String:Any]] = []
    let db = Firestore.firestore()
    
    ///setCurrentUser...
    func setCurrentUser(chef:ChefUserModel){
        self.chefUser = chef
    }
    
    ///emptyCurrentUser...
    func emptyCurrentUser(){
        chefUser = nil
    }
    
    ///getUserId...
    func getUserId()-> String {
        guard let uId = Auth.auth().currentUser?.uid else { return ""}
        return uId
    }
    
    ///isUserLogin...
    func isUserLogin()-> Bool {
        guard let _ = Auth.auth().currentUser?.uid else { return false }
        return true
    }
    
    ///checkIsUserAlreadyRegisteredOrNot...
    func checkIsUserAlreadyRegisteredOrNot(completion: @escaping (Bool)-> Void) {
        userReference.document(getUserId()).getDocument { doucument, error in
            if let _ = error { completion(false) }
            else { if doucument?.exists == true { completion(true) } else { completion(false) } }
        }
    }
    
    ///signUp...
    func signUp(email: String, password: String, completion: @escaping (APIBaseResult)-> Void){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil { completion(.failure(error?.localizedDescription ?? "")) }
            else {
                guard let _ = result else { completion(.failure(error?.localizedDescription ?? "Unable to create user")); return }
                completion(.success("User Created"))
            }
        }
    }
    
    ///signIn...
    func signIn(email: String, password: String, complection: @escaping (APIResult<AuthDataResult>)-> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil { complection(.failure(error?.localizedDescription ?? "Invalid email or password")) }
            else {
                guard let data = result else { complection(.failure(error?.localizedDescription ?? "")); return }
                complection(.success(data))
            }
        }
    }
    
    ///updateUserFCM...
    func updateUserFCM(fcm: String){
        userReference.document(getUserId()).updateData(["fcmToken" : fcm]) { error in
            if error != nil { print("FCM NOT UPDATED") } else { Constants.appCredentials.fcmToken = fcm; print("FCM UPDATED HERE....")}
        }
    }
    
    ///updateUserData...
    func setUserData(userData: ChefUserModel, completion: @escaping (APIBaseResult)-> Void) {
        userReference.document(getUserId()).setData(userData.dictionary) { error in
            if let _ = error { completion(.failure("error while updating user data")) }
            else { completion(.success("user data updated!")) }
        }
    }
    
    ///uploadImagesToServer...
    func uploadImagesToServer(image : UIImage, path: String , completion: @escaping (APIBaseResult) -> Void) {
        let ref = Storage.storage().reference().child(path)
        let metadata = StorageMetadata(); metadata.contentType = "image/jpeg"
        guard let uploadData = image.jpeg(.lowest) else { return }
        
        ref.putData(uploadData, metadata: metadata) { _, error in
            if let _ = error { completion(.failure("Faild to upload image")) }
            else {
                ref.downloadURL { url, error in
                    if let _ = error { completion( .failure("Faild to download image")) }
                    else { completion( .success(url!.absoluteString )) }
                }
            }
        }
    }
    
    ///updateChefUser...
    func updateChefUser(chef: ChefUserModel){
        userReference.document(chef.id).setData([
            "id":chef.id,
            "QBID":chef.QBID,
            "name":chef.name,
            "email":chef.email,
            "role": chef.role,
            "instagramLink":chef.instagramLink,
            "tikTokLink": chef.tikTokLink,
            "profilePic": chef.profilePic,
            "address": chef.address,
            "zipcode": chef.zipcode,
            "courses": chef.courses,
            "isRequirement": chef.isRequirement,
            "achevements": chef.achevements,
            "background": chef.background,
            "cusine": chef.cusine,
            "buyerRequests": chef.buyerRequests,
            "experties": chef.experties,
            "long": chef.long,
            "lat": chef.lat,
            "cookingIds":chef.cookingIds,
            "journey": chef.journey,
            "fcmToken": chef.fcmToken,
            "contactList": chef.contactList,
            "customerId": chef.customerId,
            "pendingClearence": chef.pendingClearence,
            "connectedAccountId": chef.connectedAccountId,
            "isAccountVarified": chef.isAccountVarified,
            "rating": chef.rating
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
            }
        }
    }
    
    ///getChefUser...
    func getChefUser(completion: @escaping( _ success: Bool, _ chef: ChefUserModel?) ->()){
        let userRef = userReference.document(Auth.auth().currentUser?.uid ?? "")
        
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
                let zipcode = data["zipcode"] as? String ?? "Not Found"
                let journey = data["journey"] as? String ?? ""
                let isRequirement = data["isRequirement"] as? Bool ?? false
                let courses = data["courses"] as? [String] ?? []
                let achevements = data["achevements"] as? [String] ?? []
                let background = data["background"] as? [String] ?? []
                let cusine = data["cusine"] as? [String] ?? []
                let experties = data["experties"] as? [String] ?? []
                let cookingIds = data["cookingIds"] as? [String] ?? []
                let buyerRequests = data["buyerRequests"] as? [String] ?? []
                let lat = data["lat"] as? Double ?? 0
                let long = data["long"] as? Double ?? 0
                let fcmToken = data["fcmToken"] as? String ?? ""
                let contactList = data["contactList"] as? [String] ?? [String]()
                let customerId = data["customerId"] as? String ?? ""
                let pendingClearence = data["pendingClearence"] as? Double ?? 0.0
                let connectedAccountId = data["connectedAccountId"] as? String ?? ""
                let isAccountVarified = data["isAccountVarified"] as? Bool ?? false
                let rating = data["rating"] as? Double ?? 0.0
    
                
                let chef = ChefUserModel(id: id, QBID: QBID, name: name, email: email, role: role, instagramLink: instagramLink, tikTokLink: tikTokLink, profilePic: profilePic, address: address, zipcode: zipcode, courses: courses, isRequirement: isRequirement, achevements: achevements, background: background, cusine: cusine, experties: experties, buyerRequests: buyerRequests ,lat: lat, long: long, journey: journey, fcmToken: fcmToken, cookingIds: cookingIds, contactList: contactList, customerId: customerId, pendingClearence: pendingClearence, connectedAccountId: connectedAccountId, isAccountVarified: isAccountVarified, rating: rating)
                completion(true,chef)
                
            } else {
                completion(false,nil)
                print("User does not exist")
            }
        }
    }
    ///getUserOfChefUser...
    func getUserOfChefUser(userID:String,handler: @escaping(_ success:Bool,_ chef:ChefUserModel?)->()){
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
                let zipcode = data["zipcode"] as? String ?? "Not Found"
                let journey = data["journey"] as? String ?? ""
                let isRequirement = data["isRequirement"] as? Bool ?? false
                let courses = data["courses"] as? [String] ?? []
                let achevements = data["achevements"] as? [String] ?? []
                let background = data["background"] as? [String] ?? []
                let cusine = data["cusine"] as? [String] ?? []
                let experties = data["experties"] as? [String] ?? []
                let cookingIds = data["cookingIds"] as? [String] ?? []
                let buyerRequests = data["buyerRequests"] as? [String] ?? []
                let lat = data["lat"] as? Double ?? 0
                let long = data["long"] as? Double ?? 0
                let fcmToken = data["fcmToken"] as? String ?? ""
                let contactList = data["contactList"] as? [String] ?? [String]()
                let customerId = data["customerId"] as? String ?? ""
                let pendingClearence = data["pendingClearence"] as? Double ?? 0.0
                let connectedAccountId = data["connectedAccountId"] as? String ?? ""
                let isAccountVarified = data["isAccountVarified"] as? Bool ?? false
                let rating = data["rating"] as? Double ?? 0.0
            
                
                let chef = ChefUserModel(id: id, QBID: QBID, name: name, email: email, role: role, instagramLink: instagramLink, tikTokLink: tikTokLink, profilePic: profilePic, address: address, zipcode: zipcode, courses: courses, isRequirement: isRequirement, achevements: achevements, background: background, cusine: cusine, experties: experties, buyerRequests: buyerRequests ,lat: lat, long: long, journey: journey, fcmToken: fcmToken, cookingIds: cookingIds, contactList: contactList, customerId: customerId, pendingClearence: pendingClearence, connectedAccountId: connectedAccountId, isAccountVarified: isAccountVarified, rating: rating)
                handler(true,chef)
                
            } else {
                handler(false,nil)
                print("Document does not exist")
            }
        }
    }
    ///getChefTodayCookings...
    func getChefTodayCookings(date: String,segmentIndex: Int,CookingsIds: [String],handler: @escaping(_ success:Bool,_ cookings: [ChefCookingModel]?)->()){
        Firestore.firestore().collection("Cookings").whereField("id", in: CookingsIds).addSnapshotListener { (snapshot, error) in
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
                    let startTime = data["startTime"] as? String ?? "Not Found"
                    let endTime = data["endTime"] as? String ?? "Not Found"
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    
                    let category = data["category"] as? String ?? "Not Found"
                    let chefName = data["chefName"] as? String ?? "Not Found"
                    let chefId = data["chefId"] as? String ?? "Not Found"
                    let images = data["images"] as? [String] ?? []
                    let ingredients = data["ingredients"] as? [Ingredient] ?? []
                    let procedure = data["procedure"] as? [String] ?? []
                    
                    let cookings = ChefCookingModel(id: id, itemName: itemName, people: people, cost: cost, difficulty: difficulty, ingredients: ingredients, procedure: procedure,images: images, pickUpLocation: pickUpLocation, lat: lat, long: long, startTime: startTime, endTime: endTime , selectedDate: selectedDate ,pickUpDateAndTime: pickUpDateAndTime, qunatity: qunatity, description: description, status: status, category: category, subCategory: subCategory,chefName: chefName,chefId: chefId)
                    
                    if date == "" {
                        let dateFormattor = DateFormatter()
                        dateFormattor.dateFormat = "dd/MM/yyyy"
                        // Today date convert into string
                        let todayDateString = dateFormattor.string(from: Date())
                        // Selected Date convert into Date Type
                        let selectStringDateToDate = dateFormattor.date(from: selectedDate)
                        // Today String type date convert into date
                        let todayStringDateToDate = dateFormattor.date(from: todayDateString)
                        
                        if segmentIndex == 0 {
                            if selectStringDateToDate ?? Date() == todayStringDateToDate{
                                array.append(cookings)
                            }else if selectStringDateToDate  ?? Date() > todayStringDateToDate ?? Date() {
                                array.append(cookings)
                            }
                           
                        }else{
                            if selectStringDateToDate ?? Date() < todayStringDateToDate ?? Date(){
                                array.append(cookings)
                            }
                        }
                    }else{
                        if date == selectedDate {
                            array.append(cookings)
                        }
                    }
                }
                handler(true,array)
            }
        }
    }
    
    ///getAllPostedLessons...
    func getAllPostedLessons(completion: @escaping (APIResult<[LessonModel]>)-> Void) {
        let db = Firestore.firestore()
        db.collection("lessons").addSnapshotListener(includeMetadataChanges: true) { snapShot, error in
            if let _ = error { completion(.failure("Error getting lessons")) }
            else {
                let postedLessons = snapShot!.documents.compactMap({ LessonModel(dictionary: $0.data()) })
                completion(.success(postedLessons))
            }
        }
    }
    
    ///getAllFoodsAndRecipies...
    func getAllFoodsAndRecipies(completion: @escaping (APIResult<[ChefCookingModel]>)-> Void) {
        let db = Firestore.firestore()
        db.collection("Cookings").getDocuments { snapShot, error in
            if let _ = error { completion(.failure("Error getting cookings")) }
            else {
                let postedFoodsAndRecipies = snapShot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoodsAndRecipies))
            }
        }
    }
    
    ///getAllFoods...
    func getAllFoods(completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting foods"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    
    ///getAllDeserts...
    func getAllDeserts(subCategory: String,completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").whereField("subCategory", isEqualTo: subCategory).getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    
    ///getAllPlantDishes...
    func getAllPlantDishes(subCategory: String,completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").whereField("subCategory", isEqualTo: subCategory).getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    ///getAllDinners...
    func getAllDinners(subCategory: String,completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").whereField("subCategory", isEqualTo: subCategory).getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    ///getAllLunches...
    func getAllLunches(subCategory: String,completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").whereField("subCategory", isEqualTo: subCategory).getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    ///getAllBreakFasts...
    func getAllBreakFasts(subCategory: String,completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "food").whereField("subCategory", isEqualTo: subCategory).getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    
    ///getAllRecipies...
    func getAllRecipies(completion: @escaping (APIResult<[ChefCookingModel]>)-> Void){
        chefcookings.whereField("category", isEqualTo: "Recipe").getDocuments { snapshot, error in
            if let _ = error {completion(.failure("Error getting recipies"))}
            else {
                let postedFoods = snapshot!.documents.compactMap({ ChefCookingModel(dictionary: $0.data()) })
                completion(.success(postedFoods))
            }
        }
    }
    
    
    ///deletePostedLesson...
    func deletePostedLesson(lessonId: String, completion: @escaping (APIBaseResult)-> Void) {
        let db = Firestore.firestore()
        db.collection("lessons").document(lessonId).delete { error in
            if let _ = error { completion(.failure("error deleting lesson")) }
            else {  completion(.success("lesson delete successfully"))  }
        }
    }
    
    
    ///getChefUploadedlessons...
    func getChefUploadedlessons(handler: @escaping(_ success:Bool,_ lessons: [LessonModel]?)->()){
        lessonReference.whereField("chefId", isEqualTo: Auth.auth().currentUser?.uid ?? "").addSnapshotListener { (snapshot, error) in
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
    ///getLessons...
    func getLessons(handler: @escaping(_ success:Bool,_ lessons: [LessonModel]?)->()){
        lessonReference.addSnapshotListener { (snapshot, error) in
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
    

    ///deleteLesson...
    func deleteLesson(id: String,handler: @escaping(_ success:Bool)->()) {
      lessonReference.document(id).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
            handler(false)
        }
        else {
          print("Document successfully removed!")
            handler(true)
        }
      }
    }
    
    ///getBuyerRequest...
    func getBuyerRequest(handler: @escaping(_ success:Bool,_ request: [BuyerRequestModel]?)->()){
        Firestore.firestore().collection("buyerRequest").addSnapshotListener { (snapshot, error) in
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
                    let amount = data["amount"] as? Double ?? 0
                    let address = data["address"] as? String ?? "Not Found"
                    let mediaURl = data["mediaURl"] as? String ?? "Not Found"
                    let foodieID = data["foodieId"] as? String ?? "Not Found"
                    let startTime = data["startTime"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let selectedDate = data["selectedDate"] as? String ?? "Not Found"
                    let accept = data["accept"] as? Bool ?? false
                    let acceptedtBy = data["acceptedtBy"] as? String ?? "Not Found"
                    
                    let userLocation = CLLocation(latitude: self.appdelegate.lat ?? 0, longitude: self.appdelegate.long ?? 0)
                    let requestLocation = CLLocation(latitude: lat, longitude: long)
                    let distance = userLocation.distance(from: requestLocation) / 1000.rounded()
                    if distance <= 15 && accept == false {
                        let request = BuyerRequestModel(id: id, description: description, category: category, timeAndDate: timeAndDate, amount: amount, lat: lat, long: long, address: address, mediaURl: mediaURl, accept: accept, acceptedtBy: acceptedtBy, foodieID: foodieID,startTime: startTime,endTime: endTime,selectedDate: selectedDate)
                        let dateFormattor = DateFormatter()
                        dateFormattor.dateFormat = "dd/MM/yyyy"
                        // Today date convert into string
                        let todayDateString = dateFormattor.string(from: Date())
                        // Selected Date convert into Date Type
                        let selectStringDateToDate = dateFormattor.date(from: selectedDate)
                        // Today String type date convert into date
                        let todayStringDateToDate = dateFormattor.date(from: todayDateString)
                        
                        if selectStringDateToDate ?? Date() == todayStringDateToDate{
                            array.append(request)
                        }else if selectStringDateToDate  ?? Date() > todayStringDateToDate ?? Date() {
                            array.append(request)
                        }
                    }
                    print("\(distance) km")
                }
                handler(true,array)
            }else{
                handler(true,array)
            }
        }
    }
    ///shareLesson...
    func shareLesson(lesson:LessonModel){
        lessonReference.document(lesson.id).setData([
            "id":lesson.id,
            "title":lesson.title,
            "description":lesson.description,
            "duration": lesson.duration,
            "tools":lesson.tools,
            "type": lesson.type,
            "chefId": lesson.chefId,
            "location": lesson.location,
            "lat": lesson.lat,
            "long": lesson.long,
            "numberOfPeople": lesson.numberOfPeople,
            "link": lesson.link,
            "additionalNotes": lesson.additionalNotes,
            "image": lesson.image,
            "createdAt": lesson.createdAt,
            "cost": lesson.cost
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
            }
        }
    }
    ///shareCookings...
    func shareCookings(cook:ChefCookingModel){
        for i in 0..<(cook.ingredients?.count ?? 0 ){
            self.ingParams.append(["id":cook.ingredients?[i].id ?? "","name":cook.ingredients?[i].name ?? "","unit":cook.ingredients?[i].unit ?? ""])
        }
        chefcookings.document(cook.id).setData([
            "id":cook.id,
            "itemName":cook.itemName,
            "people": cook.people,
            "cost": cook.cost,
            "difficulty": cook.difficulty,
            "ingredients": ingParams,
            "procedure": cook.procedure,
            "images":cook.images,
            "pickUpLocation": cook.pickUpLocation,
            "pickUpDateAndTime":cook.pickUpDateAndTime,
            "qunatity": cook.qunatity,
            "description": cook.description,
            "status": cook.status,
            "category": cook.category,
            "long": cook.long,
            "lat": cook.lat,
            "startTime": cook.startTime,
            "endTime": cook.endTime,
            "selectedDate": cook.selectedDate,
            "subCategory": cook.subCategory,
            "chefName": cook.chefName,
            "chefId": cook.chefId,
            "createdAt": FieldValue.serverTimestamp(),
        ], merge: true) { (err) in
            if let err = err {
                debugPrint("Error adding document: \(err)")
            } else {
                self.ingParams.removeAll()
            }
        }
    }
    
    ///updateContactList...
    func updateContactList(userId: String, completion: @escaping (APIBaseResult)-> Void) {
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapShotMainUser, error in
            guard let UserData = snapShotMainUser?.data(), let User = FoodieUserModel(dictionary: UserData) else { return }
            
            /// check user's contact list
            if User.contactList.contains(Auth.auth().currentUser?.uid ?? "") {
                ///getmyDocument
                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShotMainUser, error in
                    guard let myUserData = snapShotMainUser?.data(), let myUser = ChefUserModel(dictionary: myUserData) else { return }
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
                    guard let foodieData = snapShotMainUser?.data(), let foodieUser = FoodieUserModel(dictionary: foodieData) else { return }
                    
                    ///check chef's contact list
                    if foodieUser.contactList.contains(Auth.auth().currentUser?.uid ?? "") {
                        print("You're already added into foodie's list")
                    } else {
                        ///update user's conatct list
                        var updateChefContactList = foodieUser.contactList
                        print("before update foodie's contact list",updateChefContactList)
                        updateChefContactList.append(Auth.auth().currentUser?.uid ?? "")
                        print("after update foodie's contact list",updateChefContactList)
                        Firestore.firestore().collection("users").document(userId).updateData(["contactList" : updateChefContactList]) { error in
                            if error != nil { completion(.failure("chef contact List not updated")) }
                            else {
                                ///getmyDocument
                                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShotMainUser, error in
                                    guard let chefData = snapShotMainUser?.data(), let Chef = ChefUserModel(dictionary: chefData) else { return }
                                    ///check my contact list
                                    if Chef.contactList.contains(userId) {
                                        completion(.success("This user already in my contact list"))
                                    } else {
                                        ///update my conatct list
                                        var updateMyContactList = Chef.contactList
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
    
    ///updateProviderPendingClearence...
    func updatePendingClearenceOnPayment(providerUId: String, Amount: Double, completion: @escaping (APIBaseResult)-> Void) {

        //get pending clearence from selected user data...
        Firestore.firestore().collection("users").document(providerUId).getDocument { snapShot, error in
            if let _ = error {
                completion(.failure("error getting user's document")) }
            else {
                guard let data = snapShot!.data(), let userData = ChefUserModel(dictionary: data) else {
                    completion(.failure("error getting user's data")); return }
                let pendingClearence: Double = userData.pendingClearence + Amount

                //update chef's pending clearance...
                Firestore.firestore().collection("users").document(providerUId).updateData(["pendingClearence" : pendingClearence]) { error in
                    if let _ = error {
                        completion(.failure("error while updating user's pending clearence")) }
                    else {
                        completion(.success("user's pending clearence updated succefully"))
                    }
                }
            }
        }
    }
    
    func updateRating(chefId: String, rating: Double, completion: @escaping (APIBaseResult)-> Void) {

        //update chef's rating...
        Firestore.firestore().collection("users").document(chefId).updateData(["rating" : rating]) { error in
            if let _ = error {
                completion(.failure("error while updating Chef's rating")) }
            else {
                completion(.success("Chef's rating updated succefully"))
            }
        }
    }
    
    
    
    ///updateUserWithDrawID...
    func updateUserWithDrawID(id: String, complection: @escaping (APIBaseResult)-> Void) {
       
        db.collection("users").document(getUserId()).updateData(["connectedAccountId" : id]) { error in
            if error != nil {  complection(.failure("Stripe WithDraw ID UPDATED...."))} else { complection(.success("Stripe WithDraw ID NOT UPDATED...")) }
        }
    }
    
    ///updateUserWithDrawID...
    func updateUserWithDrawVerfication(value: Bool, complection: @escaping (APIBaseResult)-> Void) {
        db.collection("users").document(getUserId()).updateData(["isAccountVarified" : value]) { error in
            if error != nil {  complection(.failure("Stripe WithDraw verfication UPDATED...."))} else { complection(.success("Stripe WithDraw verfication NOT UPDATED...")) }
        }
    }
    
    ///getAllFoodieFcmIDs...
    func getAllFoodieFcmIDs(completion: @escaping (APIResult<[String]>)-> Void){
        
        let docRef = db.collection("users")
        let query = docRef.whereField("role", isEqualTo: "Foodie").whereField("notificationsAllowed", isEqualTo: true)
        
        
        query.getDocuments { snapshot, error in
            if let _ = error { completion(.failure(Constants.errorMsg)) }
            else {
                var fcmIds: [String] = []
                snapshot!.documents.forEach({
                    
                    let fcm = $0.get("fcmToken") as! String
                    fcmIds.append(fcm)
                })
                DispatchQueue.main.async { completion(.success(fcmIds)) }
            }
        }
    }
    
    ///getAllFoodieFcmIDs...
    func getAllChefFcmIDs(completion: @escaping (APIResult<[String]>)-> Void){
        
        let docRef = db.collection("users")
        let query = docRef.whereField("role", isEqualTo: "Chef")
        
        query.getDocuments { snapshot, error in
            if let _ = error { completion(.failure(Constants.errorMsg)) }
            else {
                var fcmIds: [String] = []
                snapshot!.documents.forEach({
                    
                    let fcm = $0.get("fcmToken") as! String
                    fcmIds.append(fcm)
                })
                DispatchQueue.main.async { completion(.success(fcmIds)) }
            }
        }
    }
    
    ///getAllFcmIDs...
    func getAllFcmIDs(completion: @escaping (APIResult<[String]>)-> Void){
                
        db.collection("users").getDocuments { snapshot, error in
            if let _ = error { completion(.failure(Constants.errorMsg)) }
            else {
                print("all user documents",snapshot?.documents.count as Any)
                var fcmIds: [String] = []
                snapshot!.documents.forEach({
                    let fcm = $0.get("fcmToken") as! String
                    let role = $0.get("role") as! String
                    
                    if role == "Foodie" {
                        let notificationsAllowed = $0.get("notificationsAllowed") as? Bool ?? true
                        
                        if notificationsAllowed == true {
                            fcmIds.append(fcm)
                        }
                    } else {
                        fcmIds.append(fcm)
                    }
                    
                })
                DispatchQueue.main.async { completion(.success(fcmIds)) }
            }
        }
    }
}




