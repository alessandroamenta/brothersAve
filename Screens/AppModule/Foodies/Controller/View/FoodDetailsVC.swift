//
//  FoodDetailsVC.swift
//  Food App
//
//  Created by HF on 22/12/2022.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import RappleProgressHUD

class FoodDetailsVC: UIViewController {

    //MARK: - IBoutlets...
    @IBOutlet weak var order1NameLbl:UILabel!
    @IBOutlet weak var order1PriceLbl:UILabel!
    @IBOutlet weak var pickupTimeLbl:UILabel!
    @IBOutlet weak var pickupDistanceLbl:UILabel!
    @IBOutlet weak var paymentBtn:UIButton!
    @IBOutlet weak var cancelOrderBtn:UIButton!
    @IBOutlet weak var foodImage:UIImageView!
    @IBOutlet weak var linkLocationLbl:UILabel!
    @IBOutlet weak var locationLinkStackView:UIStackView!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var locationBtn:UIButton!
    
    //MARK: - Variables...
    var foodId = ""
    var price : Double = 0.0
    let appdelgate = UIApplication.shared.delegate as! AppDelegate
    var chefId = ""
    var chefFood : ChefCookingModel?
    var lesson : LessonModel?
    var lessonId = ""
    var lat: Double?
    var long: Double?
    var request : BuyerRequestModel?
    var requestId = ""
    var orderId = ""
    var type = ""
    var service : String?
    
    //MARK: - Views's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Function...
    func setupViews(){
      
        if appCredentials.isComingfromLessons == true  {
            getLessonDetails(lessonId: lessonId)
            self.locationLinkStackView.isHidden = false
            if appCredentials.isComingfromOrders == true {
                cancelOrderBtn.isHidden = false
                paymentBtn.isHidden = true
            } else {
                cancelOrderBtn.isHidden = true
                paymentBtn.isHidden = false
                
            }
        } else if appCredentials.isComingfromFood == true {
            self.locationLinkStackView.isHidden = true
            getFoodOrRecipeDetails(foodId: foodId)
            if appCredentials.isComingfromOrders == true {
                cancelOrderBtn.isHidden = false
                paymentBtn.isHidden = true
            } else {
                cancelOrderBtn.isHidden = true
                paymentBtn.isHidden = false
            }
        } else {
            getAcceptedRequestDetails(requestId: requestId)
            if appCredentials.isComingfromOrders == true {
                cancelOrderBtn.isHidden = false
                paymentBtn.isHidden = true
            } else {
                cancelOrderBtn.isHidden = true
                paymentBtn.isHidden = false
            }
        }
    }
    
    //MARK: - Actions...
    @IBAction func backBtnAction(_ sender:UIButton){
        popViewController()
    }
    
    @IBAction func goToLocation(_ sender: UIButton){
        
        if appCredentials.isComingfromLessons == true  {
            self.locationLinkStackView.isHidden = false
            
            if self.type == "Online" {
                self.openLinkWith(urlLink: linkLocationLbl.text ?? "www.google.com")
            } else {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                    
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat!),\(long!)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:])
                    }}
                else {
                    //Open in browser
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat!),\(long!)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                    }
                }
            }
            
        } else {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat!),\(long!)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
                }}
            else {
                //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat!),\(long!)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination)
                }
            }
        }
    }
    
    @IBAction func cancelOrderBtnAction(_ sender: UIButton){
        
        let action = UIAlertAction(title: "Yes", style: .default) { action in
            self.updateDataOnCancel(providerId: self.chefId, Amount: self.price)
        }
        self.presentAlertAndGotoThatFunctionWithCancelBtn(withTitle: "are your sure to Cancel this Order?", message: "", OKAction: action, secondBtnTitle: "No")
        
    }
    
    @IBAction func goToPaymentBtnAction(_ sender:UIButton){
        
        if appCredentials.isComingfromLessons == true {
            let controller: AllCardsVC = AllCardsVC.initiateFrom(Storybaord: .chef)
            controller.amount = self.price
            controller.chefId = self.chefId
            controller.lessonId = self.lessonId
            controller.chefLesson = self.lesson
            controller.service = self.service
            self.pushViewController(viewController: controller)
        } else if appCredentials.isComingfromFood == true {
            let controller: AllCardsVC = AllCardsVC.initiateFrom(Storybaord: .chef)
            controller.foodId = self.foodId
            controller.amount = self.price
            controller.chefId = self.chefId
            controller.chefFood = self.chefFood
            controller.service = self.service
            self.pushViewController(viewController: controller)
        } else {
            let controller: AllCardsVC = AllCardsVC.initiateFrom(Storybaord: .chef)
            controller.requestId = self.requestId
            controller.amount = self.price
            controller.chefId = self.chefId
            controller.request = self.request
            controller.service = self.service
            self.pushViewController(viewController: controller)
        }
    }
}

extension FoodDetailsVC {
    
    ///getFoodOrRecipeDetails...
    func getFoodOrRecipeDetails(foodId: String){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("Cookings").document(foodId).getDocument { snapShot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Error", message: error!.localizedDescription)
                print("Error getting food/recipe detail")
            } else {
                 let foodData = snapShot!.data()
                
                let cost = foodData?["cost"] as? Double ?? 0.0
                let itemName = foodData?["itemName"] as? String ?? ""
                let lat = foodData?["lat"] as? Double ?? 0.0
                let long = foodData?["long"] as? Double ?? 0.0
                let endTime = foodData?["endTime"] as? String ?? ""
                let chefId = foodData?["chefId"] as? String ?? ""
                let imagesArray = foodData?["images"] as? [String] ?? [String]()
                let description = foodData?["description"] as? String ?? ""
                let category = foodData?["category"] as? String ?? ""
                if let image = URL(string: imagesArray[0]){
                    self.foodImage.sd_setImage(with: image, placeholderImage: nil, options: .forceTransition)
                }
                self.service = itemName
                self.chefId = chefId
                self.price = cost
                self.descriptionTextView.text = description
                self.order1NameLbl.text = itemName
                self.order1PriceLbl.text = "$\(self.price)"
                if category == "Recipe" {
                    self.pickupDistanceLbl.isHidden = true
                    self.locationBtn.isHidden = false
                } else {
                    self.pickupDistanceLbl.isHidden = false
                    self.locationBtn.isHidden = false
                    let myLocation = CLLocation(latitude: self.appdelgate.lat ?? 0, longitude: self.appdelgate.long ?? 0)
                    let chefLocation = CLLocation(latitude: lat, longitude: long)
                    let distance = myLocation.distance(from: chefLocation) / 1000
                    self.pickupDistanceLbl.text = "\(String(format: "%.1f", distance)) KM"
                }
                self.pickupTimeLbl.text = endTime
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///getLessonDetails...
    func getLessonDetails(lessonId : String){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("lessons").document(lessonId).getDocument { snapshot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Error", message: error!.localizedDescription)
                print("Error getting lesson detail")
            } else {
                let data = snapshot?.data(); let lessonData = LessonModel(dictionary: data!)
                
                self.chefId = lessonData!.chefId
                self.price = lessonData!.cost
                self.lesson = lessonData
                self.foodImage.sd_setImage(with: URL(string: lessonData?.image ?? ""))
                self.order1NameLbl.text = lessonData?.title
                self.order1PriceLbl.text = "$\(lessonData?.cost ?? 0.0)"
                self.descriptionTextView.text = lessonData?.description
                self.type = lessonData!.type
                self.service = lessonData?.title
                if self.type == "Online" {
                    self.locationBtn.isHidden = false
                    self.linkLocationLbl.text = lessonData?.link
                } else {
                    self.lat = lessonData?.lat
                    self.long = lessonData?.long
                    print("chef's coordinates", lessonData?.lat as Any,lessonData?.long as Any)
                    let myLocation = CLLocation(latitude: self.appdelgate.lat!, longitude: self.appdelgate.long!)
                    print("my coordinates:", self.appdelgate.lat as Any, self.appdelgate.long as Any)
                    let chefLocation = CLLocation(latitude: lessonData!.lat, longitude: lessonData!.long)
                    let distance = myLocation.distance(from: chefLocation) / 1000
                    self.pickupDistanceLbl.text = "\(String(format: "%.1f", distance)) KM"
                    self.linkLocationLbl.text = lessonData?.location
                    
                }
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///getAcceptedRequestDetails...
    func getAcceptedRequestDetails(requestId: String){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("acceptedBuyerRequests").document(requestId).getDocument { snapshot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Error", message: error!.localizedDescription)
                print("Error getting accepted request detail")
            } else {
                let requestdata = snapshot?.data()
                
                let image = requestdata!["mediaURl"] as? String ?? ""
                let category = requestdata!["category"] as? String ?? ""
                let description = requestdata!["description"] as? String ?? ""
                let pickupTime = requestdata!["endTime"] as? String ?? ""
                let lat = requestdata!["lat"] as? Double ?? 0.0
                let long = requestdata!["long"] as? Double ?? 0.0
                let chefId = requestdata!["acceptedtBy"] as? String ?? ""
                let amount = requestdata!["amount"] as? Double ?? 0.0
                let address = requestdata!["address"] as? String ?? ""
                self.linkLocationLbl.text = address
                self.service = category
                self.chefId = chefId
                self.price = amount
                self.requestId = requestdata!["id"] as? String ?? ""
                self.lat = lat
                self.long = long
                self.order1PriceLbl.text = "$\(amount)"
                self.order1NameLbl.text = category
                self.descriptionTextView.text = description
                self.pickupTimeLbl.text = pickupTime
                self.foodImage.sd_setImage(with: URL(string: image))
                let myLocation = CLLocation(latitude: self.appdelgate.lat ?? 0, longitude: self.appdelgate.long ?? 0)
                let chefLocation = CLLocation(latitude: lat, longitude: long)
                let distance = myLocation.distance(from: chefLocation) / 1000
                self.pickupDistanceLbl.text = "\(String(format: "%.1f", distance)) KM"
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///updateDataOnCancel...
    func updateDataOnCancel(providerId: String, Amount: Double){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.updatePendingClearenceOnCancel(providerUId: providerId, Amount: Amount) { result in
            switch result {
            case .success(let success):
                
                if appCredentials.isComingfromLessons == true  {
                    if appCredentials.isComingfromOrders == true {
                        self.deleteOrderedLessons(lessonId: self.lessonId)
                        print(success)
                    } else {
                        Alert.showMsg(msg: "Wrong selection")
                        
                    }
                } else if appCredentials.isComingfromFood == true {
                    if appCredentials.isComingfromOrders == true {
                        self.deleteOrder(orderId: self.orderId)
                        print(success)
                    } else {
                        Alert.showMsg(msg: "Wrong selection")
                    }
                } else {
                    if appCredentials.isComingfromOrders == true {
                        self.deleteCustomeOrders(requestId: self.requestId)
                        print(success)
                    } else {
                        Alert.showMsg(msg: "Wrong selection")
                    }
                }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
    }
    
    ///deleteOrder...
    func deleteOrder(orderId: String){
        FoodieService.instance.deleteOrder(orderId: orderId) { resultent in
            switch resultent {
            case .success(let success):
                RappleActivityIndicatorView.stopAnimation()
                self.getFcmAndSendNotifications(chefId: self.chefId)
                self.presentAlertAndBackToRootView(withTitle: "Alert", message:success, controller: self)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Failure", message: error)
            }
        }
    }
    
    ///deleteOrderedLessons....
    func deleteOrderedLessons(lessonId: String){
        FoodieService.instance.deleteOrderedLessons(lessonId: lessonId) { resultent in
            switch resultent {
            case .success(let success):
                RappleActivityIndicatorView.stopAnimation()
                self.getFcmAndSendNotifications(chefId: self.chefId)
                self.presentAlertAndBackToRootView(withTitle: "Alert", message:success, controller: self)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Failure", message: error)
            }
        }
    }
    
    ///deleteCustomeOrders....
    func deleteCustomeOrders(requestId: String){
        FoodieService.instance.deleteCustomOrders(requestId: requestId) { result in
            switch result {
            case .success(let success):
                RappleActivityIndicatorView.stopAnimation()
                self.getFcmAndSendNotifications(chefId: self.chefId)
                self.presentAlertAndBackToRootView(withTitle: "Alert", message:success, controller: self)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Failure", message: error)
            }
        }
    }
    
    ///getFcmAndSendNotifications...
    func getFcmAndSendNotifications(chefId: String){
        Firestore.firestore().collection("users").document(chefId).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data(); let foodieData = ChefUserModel(dictionary: data!)
                let fcm = foodieData?.fcmToken ?? ""
                print("Foodie FCM:", fcm)
                self.sendSingleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has cancelled '\(self.service!)' order", receiverToken: fcm)
            }
        }
    }
    
    ///sendSingleNotification...
    func sendSingleNotification(title: String, message: String, receiverToken: String){
        constants.servicesManager.sendSingleleNotification(title: title, message: message, receiverToken: receiverToken, completion: { resultent in
            switch resultent {
            case .success(let response):
                if response.failure == 0 {RappleActivityIndicatorView.stopAnimation();print(response.failure ?? 0)} else {RappleActivityIndicatorView.stopAnimation();print(response.success ?? 0)}
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        })
    }
    
}
