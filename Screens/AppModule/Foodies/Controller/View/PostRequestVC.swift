//
//  PostRequestVC.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 15/02/2022.
//

import UIKit
import DropDown
import AVKit
import FirebaseAuth
import RappleProgressHUD
class PostRequestVC: UIViewController {
    
    //MARK: - Proprties
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var txtViewPickUpDateAndTime: UITextView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var mediaImgeView: UIImageView!
    
    //MARK: - Vars...
    var startTime: Date?
    var endTime: Date?
    var selectDate: Date?
    var mediaSelect = ""
    var amount : Double?
    let dropDown = DropDown()
    var lat : Double?
    var long : Double?
    var address : String?
    
    private lazy var datepicker: DateTimePicker = {
        let picker = DateTimePicker()
        picker.setup()
        picker.didSelectDates = { [weak self] (startDate, endDate,selectDate) in
            let timedate = Date.buildTimeRangeString(startDate: startDate, endDate: endDate, selectDate: selectDate)
            self?.txtViewPickUpDateAndTime.text = timedate
            self?.startTime = startDate
            self?.endTime = endDate
            self?.selectDate = selectDate
        }
        return picker
    }()
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewPickUpDateAndTime.inputView = datepicker.inputView
        let lat = UserDefaults.standard.object(forKey: "FoodieLat") as? Double ?? 0.0
        let long = UserDefaults.standard.object(forKey: "FoodieLong") as? Double ?? 0.0
        let address = UserDefaults.standard.object(forKey: "FoodieAddress") as? String ?? ""
        self.lat = lat
        self.long = long
        self.address = address
        print(lat,long,address)
    }
    
    //MARK: - Supporting Functions
    
    ///submitBuyerRequest...
    func submitBuyerRequest(){
        if mediaSelect == "image" {
            RappleActivityIndicatorView.startAnimating()
            FoodieService.instance.uploadPIcture(collectionName: "BuyerRequestMedia", image: self.mediaImgeView.image ?? UIImage()) { [weak self] success, picUrl in
                if success{
                    self?.dataSaveIntoDB(mediaURL: picUrl)
                }else{
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "Something went wrong. Please try again later.")
                }
            }
        } else {
            RappleActivityIndicatorView.startAnimating()
            dataSaveIntoDB(mediaURL: "")
        }

    }
    
    ///dataSaveIntoDB...
    func dataSaveIntoDB(mediaURL: String){
        let timeFormattor = DateFormatter()
        let dateFormattor = DateFormatter()
        dateFormattor.dateFormat = "dd/MM/yyyy"
        timeFormattor.dateFormat = "hh:mm a"
        let start = timeFormattor.string(from: startTime ?? Date())
        let end = timeFormattor.string(from: endTime ?? Date())
        let date = dateFormattor.string(from: selectDate ?? Date())
        print(start,end,date)
        let amount = self.lblAmount.text?.dropFirst()
        print("amount",amount as Any)
        let request = BuyerRequestModel(id: getUniqueId(), description: txtViewDescription.text!, category: lblCategory.text!, timeAndDate: txtViewPickUpDateAndTime.text!, amount: Double(amount!) ?? 0.0,lat: self.lat ?? 0.0, long: self.long ?? 0.0, address: self.address ?? "", mediaURl: mediaURL,accept: false, acceptedtBy: "",foodieID: Auth.auth().currentUser?.uid ?? "",startTime: start , endTime: end , selectedDate: date)
        getFcmIdsAndSendNotifications(item: lblCategory.text!)
        FoodieService.instance.savebuyerRequest(request: request)
        RappleActivityIndicatorView.stopAnimation()
        Alert.showWithCompletion(msg: "Your request has been added successfully.") {
            self.popViewController()
        }
    }
    
    //MARK: - Actions...
    
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func acceptedRequestsBtnAction(_ sender: UIButton){
        print("Accepted requests tapped")
        pushViewController(storyboard: "Foodies", identifier: "AcceptedRequestsVC")
    }
    
    @IBAction func btnCategoryTapped(_ sender: UIButton) {
        dropDown.dataSource = ["Dessert","Plant based dishes","Dinner","Lunch","Breakfast"]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            self?.lblCategory.text = item
        }
    }
    @IBAction func btnAmountTapped(_ sender: UIButton) {
        dropDown.dataSource = ["$5","$10","$15","$20","$25","$30","$40","$45","$50"]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            self?.lblAmount.text = item
            print(self?.lblAmount.text)
        }
    }
    
    @IBAction func btnAddTapped(_ sender:Any){
        
        ImagePickerManager().pickImage(self) { url in
            
        } _: { image in
            self.mediaSelect = "image"
            self.mediaImgeView.image = image
        }

    }
    
    @IBAction func btnRequestSubmitTapped(_ sender: Any){
        if txtViewDescription.text == "" {
            Alert.showMsg(msg: "Please describe what do you want.")
        }else if lblCategory.text == "Category"{
            Alert.showMsg(msg: "Please select a category")
        }else if txtViewPickUpDateAndTime.text == "" {
            Alert.showMsg(msg: "Please select date and time.")

        }else if self.lblAmount.text == "Select a range" {
            Alert.showMsg(msg: "Please select an amount")

        }else{
            submitBuyerRequest()
        }
    }
}

//MARK: - Network Layers...

extension PostRequestVC {
    
    ///getFcmIdsOfFoodieUsers...
    func getFcmIdsAndSendNotifications(item:String){
        ChefService.instance.getAllChefFcmIDs { resultent in
            switch resultent {
            case .success(let fcmIds):
                print("chefs fcm ids", fcmIds)
                let fcms = Array(Set(fcmIds))
                if fcms.count >= 1 {
                    
                    self.sendMultipleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has posted request '\(item)' do check it!", receiverToken: fcms)
                }
                else { RappleActivityIndicatorView.stopAnimation();self.presentAlert(withTitle: "No One To Receive", message: "there's no one to receive") }
                
            case .failure(let error): print(error);RappleActivityIndicatorView.stopAnimation()
            }
        }
    }

    ///sendMultipleNotification...
    func sendMultipleNotification(title: String, message: String, receiverToken: [String]){
        constants.servicesManager.sendMultipleNotifications(title: title, message: message, receiverToken: receiverToken) { resultent in
            switch resultent {
            case .success(let response):
                if response.failure == 0 {RappleActivityIndicatorView.stopAnimation(); print(response.failure ?? 0) } else { RappleActivityIndicatorView.stopAnimation(); print(response.success ?? 0) }
            case .failure(let error): print(error);RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
}
