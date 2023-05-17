//
//  ChefSignUpVC.swift
//  Food App
//
//  Created by Chirp Technologies on 15/10/2021.
//

import UIKit
import Quickblox
import CryptoKit
import CoreLocation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseStorage
import FirebaseFirestore
import RappleProgressHUD
import FirebaseMessaging
import AuthenticationServices

class ChefSignUpVC: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnAlreadyHaveAnAccount: UIButton!
    @IBOutlet weak var passwordViewBtn:UIButton!

    //MARK: - Variables...
    
    //MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Functions...
    
    ///createStripeUser...
    func createStripeUser(name: String, email: String){
        constants.servicesManager.createStripeUser(email: email, name: name) { resultent in
            switch resultent {
            case .success(let response):
                print(response)
                appCredentials.customerStripeId = response.data
                appCredentials.isSocialPlatfrom = true
                let email = self.txtFieldEmail.text!
                appCredentials.email = email
                let Password = self.txtFieldPassword.text!
                let defaults = UserDefaults.standard
                defaults.set(Password, forKey: "Password")
                let userData = ChefUserModel(id: "", QBID: 0, name: "", email: email, role: "Chef", instagramLink: "", tikTokLink: "", profilePic: "", address: "", zipcode: "", courses: [String](), isRequirement: true, achevements: [String](), background: [String](), cusine: [String](), experties: [String](), buyerRequests: [String](), lat: 0.0, long: 0.0, journey: "", fcmToken: "", cookingIds: [String](), contactList: [String](), customerId: response.data ?? "", pendingClearence: 0.0,connectedAccountId: "", isAccountVarified: false, rating: 0.0)
                ChefService.instance.chefUser = userData
                let controller : TellUSVC = TellUSVC.initiateFrom(Storybaord: .chef)
                controller.chefModel = userData
                UserDefaults.standard.set("Chef", forKey: "userRole")
                self.pushViewController(viewController: controller)
                RappleActivityIndicatorView.stopAnimation()

            case .failure(let error): RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
    }
        
    @IBAction func btnAlreadyHaveAnAccountTapped(_ sender: Any){
        self.popViewController()
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
    
    @IBAction func btnSignUpTapped(_ sender: Any){
        if txtFieldEmail.isEmptyTextField() {presentAlert(withTitle: "Alert", message: "Enter email")}
        else if txtFieldPassword.isEmptyTextField() {presentAlert(withTitle: "Alert", message: "Enter password")}
        else if txtFieldPassword.text!.count < 6 { presentAlert(withTitle: "Alert", message: "The password must be 6 characters long or more")}
        else {
            RappleActivityIndicatorView.startAnimating()
            createStripeUser(name: "", email: txtFieldEmail.text!)
        }
    }
}


