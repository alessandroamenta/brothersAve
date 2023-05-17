//
//  AddCategoryVC.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 28/09/2021.
//

import UIKit
import DropDown
import CoreLocation
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore


class AddRecipeSectionVC: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var txtViewName: UITextView!
    @IBOutlet var foodImages: [UIImageView]!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var txtViewQty: UITextView!
    @IBOutlet weak var txtViewSubCategory: UITextView!
    @IBOutlet weak var txtViewPeople: UITextView!
    @IBOutlet weak var txtViewCost: UITextView!
    @IBOutlet weak var txtViewDifficulty: UITextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var tableViewProcedureHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewProcedure: UITableView!
    @IBOutlet weak var tableViewIngredientHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewIngredient: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTitle: UILabel!
    
    let subCategoryArr = ["Dessert","Plant based dishes","Dinner","Lunch","Breakfast"]
    let drop = DropDown()
    
    var lat = 0.0
    var long = 0.0
    var category: String?
    let locationManager = CLLocationManager()
    var imagesUrl = [String]()
    var imageSelect1 = false
    var imageSelect2 = false
    var imageSelect3 = false
    var imageSelect4 = false
    var index = 0
    var stepArr = [String]()
    var ingredientArr = [String]()
    
    var filledIngredientArr = [Ingredient]()
    var filledStepsArr = [String]()
    var startTime: Date?
    var endTime: Date?
    var selectDate: Date?
    var currentTable = false
    var currentChef : ChefUserModel?
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setTapGestureOnImageView()
        drop.anchorView = dropDownView
        drop.dataSource = subCategoryArr
        stepArr.append("0")
        currentTable = false
        tableViewProcedure.reloadData()
        tableViewProcedure.layoutIfNeeded()
        tableViewProcedureHeight.constant = 100
        ingredientArr.append("0")
        currentTable = true
        tableViewIngredient.reloadData()
        tableViewIngredient.layoutIfNeeded()
        tableViewIngredientHeight.constant = 100
        lblTitle.text = "Let’s make some \(category ?? "")."
        scrollView.scrollToBottom()
        
    }
    
    //MARK: - Supporting Functions
    
    func setTapGestureOnImageView(){
        foodImages.forEach { imgViews in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImagesTapped(sender:)))
            imgViews.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func handleImagesTapped(sender: UITapGestureRecognizer){
        ImagePickerManager().pickImage(self) {  ImageURl in
            
        } _: { [self] image in
            self.foodImages[sender.view?.tag ?? 0].image = image
            if sender.view?.tag == 0 {
                imageSelect1 = true
            } else if sender.view?.tag == 1 {
                imageSelect2 = true
            }
            else if sender.view?.tag == 2 {
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
    
    @IBAction func btnDropDownTapped(_ sender: Any){
        drop.show()
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.txtViewSubCategory.text = item
        }
    }
        
    @IBAction func btnAddMoreStepTapped(_ sender: Any){
        stepArr.append("0")
        currentTable = false
        tableViewProcedure.reloadData()
        tableViewProcedure.layoutIfNeeded()
        tableViewProcedureHeight.constant = tableViewProcedure.contentSize.height
        scrollView.scrollToBottom()
    }
    @IBAction func btnAddIngredientTapped(_ sender: Any){
        ingredientArr.append("0")
        currentTable = true
        tableViewIngredient.reloadData()
        tableViewIngredient.layoutIfNeeded()
        tableViewIngredientHeight.constant = tableViewIngredient.contentSize.height
        scrollView.scrollToBottom()
    }
    
    @IBAction func btnShareTapped(_ sender: Any){
        uploadCookingData()
    }
    
}

extension AddRecipeSectionVC: UITabBarDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewProcedure {
            return stepArr.count
        }
        else{
            return ingredientArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewProcedure{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProcedureStepsCell", for: indexPath) as! ProcedureStepsCell
            cell.lblStepTitle.text = "Procedure Step \(indexPath.row + 1)"
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
            cell.lblIngredientTitle.text = "Ingredient \(indexPath.row + 1)"
            cell.btnDropDown.tag = indexPath.row
            cell.initCell()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if tableView == tableViewProcedure{
                if stepArr.count > 1 {
                    stepArr.removeFirst()
                    tableViewProcedure.reloadData()
                    tableViewProcedure.layoutIfNeeded()
                    tableViewProcedureHeight.constant = tableViewProcedure.contentSize.height
                    scrollView.scrollToBottom()
                }
            }
            else{
                if ingredientArr.count > 1 {
                    ingredientArr.removeFirst()
                    tableViewIngredient.reloadData()
                    tableViewIngredient.layoutIfNeeded()
                    tableViewIngredientHeight.constant = tableViewIngredient.contentSize.height
                    scrollView.scrollToBottom()
                }
            }
        }
    }
}

class ProcedureStepsCell: UITableViewCell {
    
    @IBOutlet weak var lblStepTitle: UILabel!
    @IBOutlet weak var txtViewProcedure: UITextView!
}

class IngredientCell: UITableViewCell {
    
    @IBOutlet weak var lblIngredientTitle: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var txtViewIngredients: UITextView!
    @IBOutlet weak var txtViewUnit: UITextView!
    let unitDrop = DropDown()
    
    func initCell(){
        unitDrop.anchorView = dropDownView
        unitDrop.dataSource = ["Teaspoon","Cup"]
        btnDropDown.addTarget(self, action: #selector(handleDropOfIngredient(sender:)), for: .touchUpInside)
    }
    
    @objc func handleDropOfIngredient(sender: UIButton){
        unitDrop.show()
        unitDrop.selectionAction = {  (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.txtViewUnit.text = item
        }
    }
    
}

//MARK: - Network Layers...

extension AddRecipeSectionVC {
    
    
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
        if imageSelect1 == true && imageSelect2 == true && imageSelect3 == true && imageSelect4 == true && txtViewName.text != ""  && txtViewDescription.text != "" && txtViewSubCategory.text != ""  && txtViewQty.text != ""{
            RappleActivityIndicatorView.startAnimating()
            if index >= 4{
                for i in 0..<ingredientArr.count {
                    let indexPath = IndexPath(row: i, section: 1) // assuming cell is for first or only section of table view
                    let currentCell = tableViewIngredient.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
                    let ingr = Ingredient(id: "", name: currentCell.txtViewIngredients.text ?? "", unit: currentCell.txtViewUnit.text ?? "")
                    self.filledIngredientArr.append(ingr)
                    
                }
                for j in 0..<stepArr.count {
                    let indexPath = IndexPath(row: j, section: 1) // assuming cell is for first or only section of table view
                    let currentCell = tableViewProcedure.dequeueReusableCell(withIdentifier: "ProcedureStepsCell", for: indexPath) as! ProcedureStepsCell
                    filledStepsArr.append(currentCell.txtViewProcedure.text ?? "")
                }
                
                let id = getUniqueId()
                
                let timeFormattor = DateFormatter()
                let dateFormattor = DateFormatter()
                dateFormattor.dateFormat = "dd/MM/yyyy"
                timeFormattor.dateFormat = "hh:mm a"
                let start = timeFormattor.string(from: startTime ?? Date())
                let end = timeFormattor.string(from: endTime ?? Date())
                let date = dateFormattor.string(from: selectDate ?? Date())
                print(start,end,date)
                let cooks = ChefCookingModel(id: id, itemName: txtViewName.text!, people: txtViewPeople.text ?? "" , cost: (txtViewCost.text).toDouble(), difficulty: txtViewDifficulty.text ?? "" , ingredients: filledIngredientArr, procedure: filledStepsArr ,images: imagesUrl, pickUpLocation: "", lat: lat, long: long,startTime: start , endTime: end , selectedDate: date ,pickUpDateAndTime: "", qunatity: txtViewQty.text!, description: txtViewDescription.text!, status: "isActive", category: category ?? "", subCategory: txtViewSubCategory.text!,chefName: currentChef?.name ?? "", chefId: currentChef?.id ?? "")
                self.getFcmIdsAndSendNotifications(item: txtViewName.text!)
                ChefService.instance.shareCookings(cook: cooks)
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
                Alert.showWithCompletion(msg: "Your Recipe has been uploaded") {
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
                    self.sendMultipleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has shared a recipe of '\(item)' do check it!", receiverToken: fcms)
                }
                else { RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "No One To Receive", message: "there's no one to receive") }
                
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
            case .failure(let error): print(error)
            }
        }
    }
    
}
