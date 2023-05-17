//
//  MyProfileVC.swift
//  Food App
//
//  Created by Muneeb Zain on 12/10/2021.
//

import UIKit
import Quickblox
import FirebaseAuth
import RappleProgressHUD

class MyProfileVC: UIViewController {
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Functions
    ///clearUserData...
    func clearUserData(){
        appCredentials.pendingClearence = 0
        appCredentials.customerStripeId = ""
        appCredentials.email = ""
        appCredentials.name = ""
        appCredentials.paypal = ""
        appCredentials.chefId = ""
        UserDefaults.standard.removeObject(forKey: "isComingfromRequests")
        UserDefaults.standard.removeObject(forKey: "isComingfromFoodie")
        UserDefaults.standard.removeObject(forKey: "isComingfromLessons")
        UserDefaults.standard.removeObject(forKey: "isComingfromFood")
        UserDefaults.standard.removeObject(forKey: "isComingfromOrders")
        UserDefaults.standard.removeObject(forKey: "foodiePassword")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "FoodieLat")
        UserDefaults.standard.removeObject(forKey: "FoodieLong")
        UserDefaults.standard.removeObject(forKey: "FoodieAddress")
    }
    
    ///signOut...
    func signOut(){
        RappleActivityIndicatorView.startAnimating()
        QBRequest.logOut(successBlock: { (response) in
            try! Auth.auth().signOut()
            self.clearUserData()
            self.setNewRootViewController(storyboard: "Welcome", identifier: "WelcomeVC")
            //RappleActivityIndicatorView.stopAnimation()
            QBChat.instance.disconnect { error in
                if let error = error {
                    RappleActivityIndicatorView.stopAnimation()
                    print("Error",error)
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    print("Disconnected...")
                }
            }
        }, errorBlock: { (response) in
            RappleActivityIndicatorView.stopAnimation()
            print("Error in logout from QuickBlox")
        })
    }
    
    //MARK: - Actions
    @IBAction func viewAccountBtnPressed(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "ViewAccountVC") as! ViewAccountVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func passwordBtnPressed(_ sender: Any) {
        pushViewController(storyboard: "Chef", identifier: "ForgotPassword")
    }
    
    @IBAction func privacyPolicyBtnPressed(_ sender: Any) {
        openLinkWith(urlLink: "https://www.google.com")
    }
    
    @IBAction func notificationsBtnPressed(_ sender: Any) {
        pushViewController(storyboard: "Foodies", identifier: "NotificationSettingsVC")
    }
    
    @IBAction func btnLogoutTappeed(_ sender: Any){
        Alert.showWithTwoActions(title: "Confirm", msg: "Are you sure want to Logout?", okBtnTitle: "Yes", okBtnAction: {
            RappleActivityIndicatorView.startAnimating()
            self.signOut()
        }, cancelBtnTitle: "Cancel") {
        }
    }
}
