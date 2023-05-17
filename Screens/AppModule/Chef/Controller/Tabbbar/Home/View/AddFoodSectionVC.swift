//
//  AddRecipeVC.swift
//  Food App
//
//  Created by Chirp Technologies on 25/04/2022.
//

import UIKit
import DropDown
import CoreLocation
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore

class AddFoodSectionVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var txtViewName: UITextView!
    @IBOutlet var foodImages: [UIImageView]!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var txtViewQty: UITextView!
    @IBOutlet weak var txtViewSubCategory: UITextView!
    @IBOutlet weak var txtViewCost: UITextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtViewLocation: UITextView!
    @IBOutlet weak var txtViewPickUpDateAndTime: UITextView!
    
    //MARK: - Properties
    
    let subCategoryArr = ["Dessert","Plant based dishes","Dinner","Lunch","Breakfast"]
    let drop = DropDown()
    var category: String?
    var lat = 0.0
    var long = 0.0
    var startTime: Date?
    var endTime: Date?
    var selectDate: Date?
    var index = 0
    var currentChef : ChefUserModel?
    var imagesUrl = [String]()
    var imageSelect1 = false
    var imageSelect2 = false
    var imageSelect3 = false
    var imageSelect4 = false
    
    private lazy var datepicker: DateTimePicker = {
        let picker = DateTimePicker()
        picker.setup()
        picker.didSelectDates = { [weak self] (startDate, endDate,selectDate) in
            let timedate = Date.buildTimeRangeString(startDate: startDate, endDate: endDate, selectDate: selectDate)
            self?.startTime = startDate
            self?.endTime = endDate
            self?.selectDate = selectDate
            self?.txtViewPickUpDateAndTime.text = timedate
        }
        return picker
    }()
    
    
    //MARK: - COntroller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        txtViewPickUpDateAndTime.inputView = datepicker.inputView
        drop.anchorView = dropDownView
        drop.dataSource = subCategoryArr
        setTapGestureOnImageView()
        
    }
    
    //MARK: - Suppofting Functions
    func setTapGestureOnImageView(){
        foodImages.forEach { imgViews in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImagesTapped(sender:)))
            imgViews.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func handleImagesTapped(sender: UITapGestureRecognizer){
        ImagePickerManager().pickImage(self) {  videoURl in
            
        } _: { [self] image in
            self.foodImages[sender.view?.tag ?? 0].image = image
            if sender.view?.tag == 0 {
                imageSelect1 = true
            } else if sender.view?.tag == 1{
                imageSelect2 = true
            }
            else if sender.view?.tag == 2{
                imageSelect3 = true
            }
            else{
                imageSelect4 = true
            }
        }
    }

    
    //MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func btnPickUpLocationTapped(_ sender: Any){
        if CLLocationManager().authorizationStatus == .authorizedWhenInUse || CLLocationManager().authorizationStatus ==  .authorizedAlways{
            let controller: LocationVC = LocationVC.initiateFrom(Storybaord: .foodie)
            controller.delegate = self
            self.pushViewController(viewController: controller)
        }
        else
        {
            print("Location services are not enabled")
            Alert.showWithTwoActions(title: "Location Enabled", msg: "Please go to Settings and turn on the permissions", okBtnTitle: "Setting", okBtnAction: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
                
            }, cancelBtnTitle: "Cancel") {
                print("Cancel")
            }
        }
    }
    
    @IBAction func btnDropDownTapped(_ sender: Any){
        drop.show()
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.txtViewSubCategory.text = item
        }
    }
    
    @IBAction func btnShareTapped(_ sender: Any){
        uploadCookingData()
    }
    
}

extension AddFoodSectionVC: UITextFieldDelegate,DataPass {
    func dataPassing(searchedLocation: String, lat: Double, long: Double) {
        txtViewLocation.text = searchedLocation
        self.lat = lat
        self.long = long
        print("food lat long",lat,long)
    }
}

//MARK: - Network Layers...
extension AddFoodSectionVC {
    
    ///setupViews...
    func setupViews(){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "error getting user's data")
            }
            else {
                guard let myData = snapShot!.data(), let myUser = ChefUserModel(dictionary: myData) else {
                    return
                }
                self.currentChef = myUser
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///uploadCookingData...
    func uploadCookingData(){
        if imageSelect1 == true && imageSelect2 == true && imageSelect3 == true && imageSelect4 == true && txtViewName.text != ""  && txtViewDescription.text != "" && txtViewSubCategory.text != ""  && txtViewQty.text != "" && txtViewLocation.text != ""{
            RappleActivityIndicatorView.startAnimating()
            if index >= 4{
                let id = getUniqueId()
                
                let timeFormattor = DateFormatter()
                let dateFormattor = DateFormatter()
                dateFormattor.dateFormat = "dd/MM/yyyy"
                timeFormattor.dateFormat = "hh:mm a"
                let start = timeFormattor.string(from: startTime ?? Date())
                let end = timeFormattor.string(from: endTime ?? Date())
                let date = dateFormattor.string(from: selectDate ?? Date())
                print(start,end,date)
                let cooks = ChefCookingModel(id: id, itemName: txtViewName.text!, people: txtViewQty.text! , cost: (txtViewCost.text).toDouble(), difficulty:  "" , ingredients: [], procedure: [] ,images: imagesUrl, pickUpLocation: txtViewLocation.text!, lat: lat , long: long ,startTime: start, endTime: end, selectedDate: date ,pickUpDateAndTime: txtViewPickUpDateAndTime.text!, qunatity: txtViewQty.text!, description: txtViewDescription.text!, status: "isActive", category: "food", subCategory: txtViewSubCategory.text!,chefName: currentChef?.name ?? "", chefId: currentChef?.id ?? "")
                ChefService.instance.shareCookings(cook: cooks)
                self.getFcmIdsAndSendNotifications(item: txtViewName.text!)
                currentChef!.cookingIds.append(id)
                ChefService.instance.updateChefUser(chef: currentChef!)
                ChefService.instance.setCurrentUser(chef: currentChef!)
                self.txtViewQty.text = ""
                self.txtViewName.text = ""
                self.txtViewDescription.text = ""
                self.imageSelect1 = false
                self.imageSelect2 = false
                self.imageSelect3 = false
                self.imageSelect4 = false
                RappleActivityIndicatorView.stopAnimation()
                Alert.showWithCompletion(msg: "Your Food has been uploaded") {
                    self.popViewController()
                }
                return
            }
            FoodieService.instance.uploadPIcture(collectionName: "ChefCookingsPicture", image: foodImages[index].image ?? UIImage()) {[self] success, picUrl in
                if success{
                    self.imagesUrl.append(picUrl)
                    index = index + 1
                    uploadCookingData()
                }
                else{
                    index = index + 1
                    uploadCookingData()
                }
            }
        }
        else{
            
            Alert.showMsg(msg: "Please fill the missing requirement.")
        }
    }
    
    ///getFcmIdsOfFoodieUsers...
    func getFcmIdsAndSendNotifications(item:String){
        ChefService.instance.getAllFoodieFcmIDs { resultent in
            switch resultent {
            case .success(let fcmIds):
                print("foodies fcm ids", fcmIds)
                let fcms = Array(Set(fcmIds))
                if fcms.count >= 1 {
                    
                    self.sendMultipleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has shared a food item '\(item)' do check it!", receiverToken: fcms)
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
