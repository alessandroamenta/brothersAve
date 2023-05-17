//
//  AllCardsVC.swift
//  Food App
//
//  Created by HF on 02/01/2023.
//

import UIKit
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore

class AllCardsVC: UIViewController {
    
    //MARK: - Outlet...
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var cardsCollectionViewsHeightAnchor: NSLayoutConstraint!
    
    
    //MARK: - varibales...
    let cellIdentier = CardsCollectionCell().identifier
    let cellSize: CGFloat = 100.0, cellSpace = 0.0
    var allCards: [PaymentMethodResponse] = []
    var delegate: CardSelectionDelegate?
    var amount : Double?
    var chefId : String?
    var foodId : String?
    var chefFood : ChefCookingModel?
    var chefLesson : LessonModel?
    var lessonId : String?
    var request : BuyerRequestModel?
    var requestId : String?
    var service : String?
    
    //MARK: - View Life Cycle...
    
    ///viewDidLoad...
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    ///viewDidLayoutSubviews...
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllSavedCard()
    }
   
    //MARK: - Functions...
    
    ///updateViewDidLayoutSubviews...
    func updateViewDidLayoutSubviews(){ DispatchQueue.main.async {
        self.cardsCollectionViewsHeightAnchor.constant = self.cardCollectionView.contentSize.height
    } }
    
    ///setUpViews...
    func setUpViews(){
        setUpCollectionView();
        getCustomerId()
        if appCredentials.isComingfromFood == true {
            print(chefId as Any,foodId as Any,chefFood as Any,service as Any)
        } else if appCredentials.isComingfromLessons == true {
            print(chefId as Any,lessonId as Any,chefLesson as Any,service as Any)
        } else {
            print(chefId as Any,requestId as Any,request as Any,service as Any)
        }
        
    }
    
    ///setUpCollectionView...
    func setUpCollectionView(){
        cardCollectionView.register(UINib(nibName: "CardsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CardsCollectionCell")
    }
    
    
    //MARK: - Button Actions...
    
    ///backBtnAction...
    @IBAction func backBtnAction(_ sender: Any) { self.popViewController() }
    
    ///addNewCardBtnAction...
    @IBAction func addNewCardBtnAction(_ sender: Any) {
        pushViewController(storyboard: "Chef", identifier: "PaymentMethodsVC")

    }
    
}

// MARK: - Collectionview delegate and Datasource...
extension AllCardsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCollectionCell", for: indexPath) as! CardsCollectionCell
        cell.data = allCards[indexPath.item]; cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: cellSize)
    }
      
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = UIAlertAction(title: "Yes", style: .default) { action in
            let selectedCard = self.allCards[indexPath.item]
            if appCredentials.isComingfromLessons == true {
                self.checkLessonOrder(providerId: self.chefId ?? "", lessonId: self.lessonId ?? "", cardId: selectedCard.id ?? "", amount: self.amount ?? 0.0, service: self.service ?? "")
            } else if appCredentials.isComingfromFood == true {
                self.checkOrder(providerId: self.chefId ?? "", foodId: self.foodId ?? "", cardId: selectedCard.id ?? "", amount: self.amount ?? 0.0, service: self.service ?? "")
            } else {
                self.checkCustomOrder(providerId: self.chefId ?? "", requestId: self.requestId ?? "", cardId: selectedCard.id ?? "", amount: self.amount ?? 0.0, service: self.service ?? "")
            }
        }
        self.presentAlertAndGotoThatFunctionWithCancelBtn(withTitle: "Do you want to pay with this Card?", message: "", OKAction: action, secondBtnTitle: "No")
    }
    
}


//MARK: - Networking Layers...
extension AllCardsVC {
    
    func didTapOnDeleteCardBtn(card: PaymentMethodResponse){
        let action = UIAlertAction(title: "Yes", style: .default) { action in
            guard let pmid = card.id else { return }; self.deletePayemntCard(pmid: pmid)
        }
        self.presentAlertAndGotoThatFunctionWithCancelBtn(withTitle: "Are you sure to delete Payment Card?", message: "", OKAction: action, secondBtnTitle: "No")
    }
}

// MARK: - Network Layers...
extension AllCardsVC {
    
    ///getCustomerId...
    func getCustomerId(){
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {  }
            else {
                guard let myData = snapShot!.data(), let myUser = FoodieUserModel(dictionary: myData) else {
                    return
                }
                appCredentials.customerStripeId = myUser.customerId
                print("CustomerStripeId", appCredentials.customerStripeId!)
            }
        }
    }
    
    ///getAllSavedCard...
    func getAllSavedCard(){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.getAllStripeCards(customerId: appCredentials.customerStripeId ?? "") { resultent in
            switch resultent {

            case .success(let response):
                RappleActivityIndicatorView.stopAnimation()
                self.allCards = response.paymentMethod ?? []
                print(self.allCards.count)
                if self.allCards.count <= 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    self.presentAlert(withTitle: "Alert", message: "No Payment Card added. Please click on + to add new Payment card")
                    self.cardCollectionView.reloadData(); self.viewDidLayoutSubviews()
                }
                else {
                    RappleActivityIndicatorView.stopAnimation()
                    DispatchQueue.main.async {
                        
                        self.cardCollectionView.reloadData()
                        self.viewDidLayoutSubviews()
                    }
                    
                }
            case .failure(let error):
                print(error)
                RappleActivityIndicatorView.stopAnimation()
                self.cardCollectionView.reloadData()
            }
        }
    }
    
    ///checkOrder...
    func checkOrder(providerId: String,foodId: String, cardId: String, amount:Double, service: String){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.checkOrderExist(foodId: foodId) { isExist in
            switch isExist {
            case .success(let response):
                if response == true {
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "Your order has already been created ")
                } else {
                    print("Order does not exist in your list")
                    ChefService.instance.getUserOfChefUser(userID: self.chefFood!.chefId) { success, chef in
                        if success{

                            var qty = Int(self.chefFood!.qunatity)
                            if qty! <= 0 {
                                Alert.showMsg(msg: "This item is not available right now")
                            } else {
                                qty = (qty! - 1)
                                self.chefFood!.qunatity = "\(qty ?? 0)"
                            }
                            self.chargeStripeAmountNow(providerId: providerId, customerId: appCredentials.customerStripeId ?? "", paymentMethodId: cardId, amount: amount, service: service)
                        }else{
                            RappleActivityIndicatorView.stopAnimation()
                        }
                    }
                }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
            }
        }
    }
    
    ///chargeStripeAmountNow...
    func chargeStripeAmountNow(providerId: String,customerId: String, paymentMethodId: String, amount: Double, service: String){
        
        constants.servicesManager.chargeStripeAmountNow(customerId: customerId, paymentMethodId: paymentMethodId, amount: amount) { resultent in
            switch resultent {
                
            case .success(let response):
                print("general stripe response ", response)
                if response.status == "ok" {
                    print("charge stripe success response :", response)
                    self.updateDataAfterCharge(providerId: providerId, Amount: amount)
                    ChefService.instance.shareCookings(cook: self.chefFood!)
                    FoodieService.instance.createOrder(cook: self.chefFood!, foodieId: Auth.auth().currentUser?.uid ?? "")
                    self.getFcmAndSendNotifications(chefId: self.chefId!, service: service, amount: amount)
                    self.presentAlertAndBackToRootView(withTitle: "Alert", message: "Your order has been created. You can see in your order section", controller: self)
                    print(response.message!)
                    
                }
                else {
                    RappleActivityIndicatorView.stopAnimation(); Alert.showMsg(msg: "try again") }
            case .failure(_): RappleActivityIndicatorView.stopAnimation(); self.presentErrorAlert()
            }
        }
    }
        
    ///checkLessonOrder...
    func checkCustomOrder(providerId:String, requestId:String, cardId:String, amount: Double, service: String){
        RappleActivityIndicatorView.startAnimating()
        
        FoodieService.instance.checkOrderRequestExist(requestId: requestId) { resultent in
            switch resultent {
            case .success(let response):
                if response == true {
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "This request already exist in your list")
                } else {
                    ChefService.instance.getUserOfChefUser(userID: self.chefId ?? "") { success, chef in
                        if success {
                            self.chargeStripeAmountonCustomeRequests(providerId: providerId, customerId: appCredentials.customerStripeId ?? "", paymentMethodId: cardId, amount: amount, service: service)
                        } else {
                            RappleActivityIndicatorView.stopAnimation()
                        }
                    }
                }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
            }
        }
    }
    
    ///chargeStripeAmountNow...
    func chargeStripeAmountonCustomeRequests(providerId: String,customerId: String, paymentMethodId: String, amount: Double, service: String){
        
        constants.servicesManager.chargeStripeAmountNow(customerId: customerId, paymentMethodId: paymentMethodId, amount: amount) { resultent in
            switch resultent {
                
            case .success(let response):
                print("general stripe response ", response)
                if response.status == "ok" {
                    print("charge stripe success response :", response)
                    self.updateDataAfterCharge(providerId: providerId, Amount: amount)
                    FoodieService.instance.createBuyerRequestOrder(request: self.request!, acceptedBy: providerId)
                    self.getFcmAndSendNotifications(chefId: self.chefId!, service: service, amount: amount)
                    self.presentAlertAndBackToRootView(withTitle: "Alert", message: "Your order has been created. You can see in your order section", controller: self)
                    print(response.message!)
                    
                }
                else {
                    
                    RappleActivityIndicatorView.stopAnimation(); Alert.showMsg(msg: "try again") }
            case .failure(_): RappleActivityIndicatorView.stopAnimation(); self.presentErrorAlert()
            }
        }
    }
    
    ///checkLessonOrder...
    func checkLessonOrder(providerId:String, lessonId:String, cardId:String, amount: Double, service: String){
        RappleActivityIndicatorView.startAnimating()
        
        FoodieService.instance.checkOrderLessonExist(lessonId: lessonId) { resultent in
            switch resultent {
            case .success(let response):
                if response == true {
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "This lesson already exist in your order list")
                } else {
                    ChefService.instance.getUserOfChefUser(userID: self.chefLesson!.chefId) { success, chef in
                        if success {
                            self.chargeStripeAmountOnLesson(providerId: providerId, customerId: appCredentials.customerStripeId ?? "", paymentMethodId: cardId, amount: amount, service: service)
                        } else {
                            RappleActivityIndicatorView.stopAnimation()
                        }
                    }
                }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
            }
        }
    }
    
    ///chargeStripeAmountNow...
    func chargeStripeAmountOnLesson(providerId: String,customerId: String, paymentMethodId: String, amount: Double, service: String){
        
        constants.servicesManager.chargeStripeAmountNow(customerId: customerId, paymentMethodId: paymentMethodId, amount: amount) { resultent in
            switch resultent {
                
            case .success(let response):
                print("general stripe response ", response)
                if response.status == "ok" {
                    print("charge stripe success response :", response)
                    self.updateDataAfterCharge(providerId: providerId, Amount: amount)
                    ChefService.instance.shareLesson(lesson: self.chefLesson!)
                    FoodieService.instance.updateOrderedLessons(lesson: self.chefLesson!, foodieId: Auth.auth().currentUser?.uid ?? "")
                    self.getFcmAndSendNotifications(chefId: self.chefId!, service: service, amount: amount)
                    self.presentAlertAndBackToRootView(withTitle: "Alert", message: "Your order has been created. You can see in your order section", controller: self)
                    print(response.message!)
                    
                }
                else {
                    
                    RappleActivityIndicatorView.stopAnimation(); Alert.showMsg(msg: "try again") }
            case .failure(_): RappleActivityIndicatorView.stopAnimation(); self.presentErrorAlert()
            }
        }
    }
    
    ///updateDataAfterCharge...
    func updateDataAfterCharge(providerId: String, Amount: Double){
        
        ChefService.instance.updatePendingClearenceOnPayment(providerUId: providerId, Amount: Amount) { result in
            switch result {
            case .success(let success):
                RappleActivityIndicatorView.stopAnimation()
                print(success)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
    }
    
    ///deletePayemntCard...
    func deletePayemntCard(pmid: String){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.deletePaymentCard(pmid: pmid) { resultent in
            switch resultent {

            case .success(let response): print(response)
                if response.status == "ok" {
                    RappleActivityIndicatorView.stopAnimation(); self.getAllSavedCard(); self.presentAlert(withTitle: "Alert", message: "Payment card delete successfully")
                }
                else { RappleActivityIndicatorView.stopAnimation(); Alert.showMsg(msg: "try again")}
            case .failure(let error): print(error); RappleActivityIndicatorView.stopAnimation(); self.presentErrorAlert()
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
    
    ///getFcmAndSendNotifications...
    func getFcmAndSendNotifications(chefId: String, service: String, amount:Double){
        Firestore.firestore().collection("users").document(chefId).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data(); let foodieData = ChefUserModel(dictionary: data!)
                let fcm = foodieData?.fcmToken ?? ""
                print("Foodie FCM:", fcm)
                self.sendSingleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has paid '$\(amount)' for '\(service)'", receiverToken: fcm)
            }
        }
    }
}

