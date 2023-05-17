//
//  ReadyToGoVC.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 28/09/2021.
//

import UIKit
import Quickblox
import FirebaseAuth
import CoreLocation
import YPImagePicker
import RappleProgressHUD
import FirebaseFirestore

class ReadyToGoVC: UIViewController {
    
    //MARK: - Proprties
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var txtViewName: UITextView!
    @IBOutlet weak var txtViewAddress: UITextView!
    @IBOutlet weak var txtViewZipCode: UITextView!
    @IBOutlet weak var txtViewCourse1: UITextView!
    @IBOutlet weak var txtViewCourse2: UITextView!
    @IBOutlet weak var txtViewAchevment1: UITextView!
    @IBOutlet weak var txtViewAchevment2: UITextView!
    
    // MARK: - Variables
    var chefModel : ChefUserModel?
    let locationManager = CLLocationManager()
    var lat = 0.0
    var long = 0.0
    let defaults = UserDefaults.standard
    var selectedImagesFromGallary = [UIImage]()
    var imageUrl = ""
    var userId = ""
    var newUser = QBUUser()
    var QBID : UInt = 0
    var courseArr = [String]()
    var achievementArr = [String]()
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Functions
    func setupViews(){
        if appCredentials.isSocialPlatfrom == false {
            txtViewName.text = appCredentials.name ?? ""
            profileImageView.sd_setImage(with: URL(string: constants.appCredentials.imageURL ?? ""))
        }
        profileImageView.cornerRadius = 15
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image?.withAlignmentRectInsets(UIEdgeInsets(top: 0 , left: 0, bottom: 0, right: 0))
    }

    
    //MARK: - Actions
    @IBAction func btnBackTappeed(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func btnUplaodTapped(_ sender: Any){
        self.didTapForProfilePic()
    }
    
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
    
    @IBAction func btnCancel(_ sender: Any){
        
    }
    
    @IBAction func btnNext(_ sender: Any){
        
        
        if appCredentials.isSocialPlatfrom == true  {
            if profileImageView.image == nil {presentAlert(withTitle: "Alert", message: "Select profile image")}
            else if txtViewName.isEmptyTextView() {presentAlert(withTitle: "Alert", message: "Enter name")}
            else if txtViewZipCode.isEmptyTextView() {presentAlert(withTitle: "Alert", message: "Enter zipcode")}
            else if txtViewAddress.isEmptyTextView() {presentAlert(withTitle: "Alert", message: "Enter address")}
            else {
                RappleActivityIndicatorView.startAnimating()
                getImageUrlString { imageUrl in
                    self.courseArr.append(self.txtViewCourse1.text)
                    self.courseArr.append(self.txtViewCourse2.text)
                    self.achievementArr.append(self.txtViewAchevment1.text)
                    self.achievementArr.append(self.txtViewAchevment2.text)
                    self.chefModel?.profilePic = imageUrl
                    self.chefModel?.name = self.txtViewName.text!
                    self.chefModel?.zipcode = self.txtViewZipCode.text!
                    self.chefModel?.address = self.txtViewAddress.text!
                    self.chefModel?.courses = self.courseArr
                    self.chefModel?.achevements = self.achievementArr
                    self.signUpNow()
                }
            }
        } else {
            if txtViewZipCode.isEmptyTextView() {presentAlert(withTitle: "Alert", message: "Enter zipcode")}
            else if txtViewAddress.isEmptyTextView() {presentAlert(withTitle: "Alert", message: "Enter address")}
            else {
                RappleActivityIndicatorView.startAnimating()
                self.courseArr.append(self.txtViewCourse1.text)
                self.courseArr.append(self.txtViewCourse2.text)
                self.achievementArr.append(self.txtViewAchevment1.text)
                self.achievementArr.append(self.txtViewAchevment2.text)
                self.chefModel?.profilePic = constants.appCredentials.imageURL ?? ""
                self.chefModel?.name = appCredentials.name ?? ""
                self.chefModel?.zipcode = self.txtViewZipCode.text!
                self.chefModel?.address = self.txtViewAddress.text!
                self.chefModel?.courses = self.courseArr
                self.chefModel?.achevements = self.achievementArr
                self.updateChefUser(userId: appCredentials.uid ?? "")
            }
        }
    }
    
    
}
///extension...
extension ReadyToGoVC: UITextFieldDelegate,DataPass {
    func dataPassing(searchedLocation: String, lat: Double, long: Double) {
        txtViewAddress.text = searchedLocation
        self.lat = lat
        self.long = long
        self.chefModel?.lat = lat
        self.chefModel?.long = long
        print(lat,long)
    }
}
///extension...
extension ReadyToGoVC {
    
    ///didTapForProfilePic...
    func didTapForProfilePic(){
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.selectedImagesFromGallary.removeAll()
                self.selectedImagesFromGallary.append(photo.image)
                self.profileImageView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    ///getImageUrlString...
    func getImageUrlString(completion: @escaping (String)-> Void) {
        if selectedImagesFromGallary.count >= 1 {
            uploadImageToServer(completion: { url in completion(url) }) }
        else if selectedImagesFromGallary.count == 0 { completion("") }
    }
    
    ///randomString...
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    ///uploadServerImageToServer...
    func uploadImageToServer( completion: @escaping (String)-> Void) {
        let path = "chef_profile_photo/\(randomString(length: 5)).jpg"
        guard let image = selectedImagesFromGallary.first else { completion(""); return }
        ChefService.instance.uploadImagesToServer(image: image, path: path) { resultent in
            switch resultent {
            case .success(let url): print(url); completion(url)
            case .failure(let error): print(error); completion("")
            }
        }
    }
    
    func signUpNow(){
        let Email = chefModel?.email ?? ""
        let Password = self.defaults.object(forKey: "Password") as? String ?? ""
        ///signUp With Firebase...
        ChefService.instance.signUp(email: Email, password: Password) { resultent in
            switch resultent {
            case .success(_):
                RappleActivityIndicatorView.stopAnimation()
                self.newUser.login = Email; self.newUser.password = Password
                DispatchQueue.main.async {
                    ///signUp With Quickblox...
                    QBRequest.signUp(self.newUser, successBlock: { response, user in
                        self.QBID = user.id; let id = Auth.auth().currentUser?.uid; self.userId = id!
                        self.chefModel?.QBID = self.QBID; self.chefModel?.id = id!
                        /// login with quickblox...
                        QBRequest.logIn(withUserLogin: Email , password: Password, successBlock: { (response, user) in
                            
                            self.updateChefUser(userId: id!)
                            
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
    
    ///updateChefUser...
    func updateChefUser(userId: String){
        let db =  Firestore.firestore().collection("users")
        db.document(userId).setData([
            "id": self.chefModel?.id ?? "",
            "QBID": self.chefModel?.QBID ?? 0,
            "name": self.chefModel?.name ?? "",
            "email": self.chefModel?.email ?? "",
            "role": self.chefModel?.role ?? "",
            "instagramLink": self.chefModel?.instagramLink ?? "",
            "tikTokLink": self.chefModel?.tikTokLink ?? "",
            "profilePic": self.chefModel?.profilePic ?? "",
            "address": self.chefModel?.address ?? "",
            "zipcode": self.chefModel?.zipcode ?? "",
            "courses": self.chefModel?.courses ?? [],
            "isRequirement": self.chefModel?.isRequirement ?? true,
            "achevements": self.chefModel?.achevements ?? [],
            "background": self.chefModel?.background ?? [],
            "cusine": self.chefModel?.cusine ?? [],
            "buyerRequests": self.chefModel?.buyerRequests ?? "",
            "experties": self.chefModel?.experties ?? [],
            "long": self.chefModel?.long ?? 0.0 ,
            "lat": self.chefModel?.lat ?? 0.0,
            "cookingIds": self.chefModel?.cookingIds ?? [],
            "journey": self.chefModel?.journey ?? "",
            "fcmToken": self.chefModel?.fcmToken ?? "",
            "contactList": self.chefModel?.contactList ?? [],
            "customerId": self.chefModel?.customerId ?? "",
            "pendingClearence": self.chefModel?.pendingClearence ?? 0.0,
            "connectedAccountId": self.chefModel?.connectedAccountId ?? "",
            "isAccountVarified": self.chefModel?.isAccountVarified ?? false,
            "rating": self.chefModel?.rating ?? 0.0
        ], merge: true) { (err) in
            if let err = err {
                RappleActivityIndicatorView.stopAnimation()
                self.presentAlert(withTitle: "Alert", message: err.localizedDescription)
            } else {
                RappleActivityIndicatorView.stopAnimation()
                UserDefaults.standard.set("Chef", forKey: "userRole")
                let controller: TabbarVC = TabbarVC.initiateFrom(Storybaord: .chef)
                self.setNewRootViewController(storyboard: "Chef", identifier: "TabbarVC")
                ChefService.instance.chefUser = self.chefModel
                self.pushViewController(viewController: controller)
            }
        }
    }
}
