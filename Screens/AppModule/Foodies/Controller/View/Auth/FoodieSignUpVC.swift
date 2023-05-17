//
//  FoodieSignUpVC.swift
//  Food App
//
//  Created by Chirp Technologies on 15/10/2021.
//

import UIKit
import Quickblox
import CoreLocation
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore
import RappleProgressHUD

class FoodieSignUpVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtViewAddress: UITextView!
    @IBOutlet weak var txtFieldZipCode: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnAlreadyHaveAnAccount: UIButton!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordViewBtn:UIButton!
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    let newUser = QBUUser()
    var QBID : UInt?
    var uid = ""
    var foodie : FoodieUserModel?
    var lat = 0.0
    var long = 0.0
    var customerId = ""
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Functions...
    ///setupViews...
    func setupViews(){
        if appCredentials.isSocialPlatfrom == false {
            txtFieldName.text = appCredentials.name ?? ""
            txtFieldEmail.text = appCredentials.email ?? ""
            txtFieldPassword.isUserInteractionEnabled = false
        }
    }
    
    ///createStripeUser...
    func createStripeUser(){
        RappleActivityIndicatorView.startAnimating()
        let Name = txtFieldName.text!
        let Email = txtFieldEmail.text!
        let address = txtViewAddress.text!
        let zipCode = txtFieldZipCode.text!
        
        constants.servicesManager.createStripeUser(email: Email, name: Name) { resultent in
            switch resultent {
            case .success(let response):
               print("API Response",response)
                appCredentials.customerStripeId = response.data
                self.customerId = response.data ?? ""
                print(self.customerId)
                UserDefaults.standard.set("Foodie", forKey: "userRole")
                let foodie = FoodieUserModel(id: self.uid, QBID: self.QBID ?? 0, name: Name, email: Email, role: "Foodie", instagramLink: "", tikTokLink: "", profilePic: "",address: address,zipCode: zipCode, fcmToken: Constants.appCredentials.fcmToken ?? "", lat: self.lat , long: self.long, contactList: [String](), customerId: self.customerId, pendingClearence: 0.0, notificationsAllowed: true)
                FoodieService.instance.FoodieUser = foodie
                FoodieService.instance.setCurrentUser(foodie: foodie)
                FoodieService.instance.updateFoodieUser(foodie: foodie)
                let controller: tabBarVC = tabBarVC.initiateFrom(Storybaord: .foodie)
                self.setNewRootViewController(storyboard: "Foodies", identifier: "tabBarVC")
                self.pushViewController(viewController: controller)
                RappleActivityIndicatorView.stopAnimation()
                
            case .failure(let error): RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
    }
        
    ///signUpNow...
    func signUpNow(){
        
        let Email = txtFieldEmail.text!
        let Password = txtFieldPassword.text!
        UserDefaults.standard.set(Password, forKey: "foodiePassword")
        ///signUp With Firebase...
        ChefService.instance.signUp(email: Email, password: Password) { resultent in
            switch resultent {
            case .success(_):
                
                self.newUser.login = Email; self.newUser.password = Password
                DispatchQueue.main.async {
                    ///signUp With Quickblox...
                    QBRequest.signUp(self.newUser, successBlock: { response, user in
                        self.QBID = user.id; self.uid = Auth.auth().currentUser?.uid ?? "";
                        /// login with quickblox...
                        QBRequest.logIn(withUserLogin: Email , password: Password, successBlock: { (response, user) in
                            
                            ///createAccountWithPostMan...
                            self.createStripeUser()
                        }, errorBlock: { (response) in
                            RappleActivityIndicatorView.stopAnimation()
                            self.presentAlert(withTitle: "Alert", message: "something went wrong")
                        })
                    }, errorBlock: { (response) in
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlert(withTitle: "Alert", message: "something went wrong")
                    })
                }
            case .failure(let error): RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Error", message: error)
            }
        }
    }

    ///updateFoodieUser...
    func updateFoodieUser(userId:String){
        let db = Firestore.firestore().collection("users")
         
        db.document(userId).setData([
            "id": self.foodie?.id ?? "",
            "QBID": self.foodie?.QBID ?? 0,
            "name": self.foodie?.name ?? "",
            "email": self.foodie?.email ?? "",
            "role": self.foodie?.role ?? "",
            "instagramLink": self.foodie?.instagramLink ?? "",
            "tikTokLink": self.foodie?.tikTokLink ?? "",
            "profilePic": self.foodie?.profilePic ?? "",
            "address": self.foodie?.address ?? "",
            "zipCode": self.foodie?.zipCode ?? "",
            "long": self.foodie?.long ?? "",
            "lat": self.foodie?.lat ?? "",
            "fcmToken": self.foodie?.fcmToken ?? "",
            "contactList": self.foodie?.contactList ?? [],
            "customerId": self.foodie?.customerId ?? "",
            "pendingClearence": self.foodie?.pendingClearence ?? 0.0,
            "notificationsAllowed": self.foodie?.notificationsAllowed ?? true
        ], merge: true) { (err) in
            if let err = err {
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Alert", message: err.localizedDescription)
            } else {
                RappleActivityIndicatorView.stopAnimation()
                UserDefaults.standard.set("Foodie", forKey: "userRole")
                let controller: tabBarVC = tabBarVC.initiateFrom(Storybaord: .foodie)
                self.setNewRootViewController(storyboard: "Foodies", identifier: "tabBarVC")
                FoodieService.instance.FoodieUser = self.foodie
                self.pushViewController(viewController: controller)
            }
        }
    }

    //MARK: - Actions
    
    @IBAction func btnLocationTapped(_ sender: Any){
        
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
    
    @IBAction func passwordViewBtnAction(_ sender: UIButton){
        if txtFieldPassword.isSecureTextEntry {
            txtFieldPassword.isSecureTextEntry = false
            passwordViewBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            passwordViewBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            txtFieldPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnAlreadyHaveAnAccountTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func btnSignUpTapped(_ sender: Any){
        
        if appCredentials.isSocialPlatfrom == false {
            if txtFieldZipCode.text != "" && txtViewAddress.text  != "" {
                RappleActivityIndicatorView.startAnimating()
                txtFieldName.text = appCredentials.name
                let zipCode = txtFieldZipCode.text!
                let address = txtViewAddress.text!
                self.foodie?.zipCode = zipCode
                self.foodie?.address = address
                updateFoodieUser(userId: appCredentials.uid ?? "")
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Please fill requirement")
            }
            
        } else {
            if txtFieldZipCode.text != "" && txtViewAddress.text  != ""  && txtFieldPassword.text != ""  && txtFieldName.text != "" && txtFieldEmail.text != "" {
                RappleActivityIndicatorView.startAnimating()
                signUpNow()
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Please fill requirement")
            }
        }
    }
}

extension FoodieSignUpVC: UITextFieldDelegate,DataPass {
    
    ///dataPassing...
    func dataPassing(searchedLocation: String, lat: Double, long: Double) {
        
        txtViewAddress.text = searchedLocation
        self.lat = lat
        self.long = long
        self.foodie?.lat = lat
        self.foodie?.long = long
        print(lat,long)
    }
}

