//
//  NotificationSettingsVC.swift
//  Food App
//
//  Created by HF on 11/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RappleProgressHUD

class NotificationSettingsVC: UIViewController {

    //MARK: - IBoutlets...
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var notificationsOnOffLbl:UILabel!
    
    //MARK: - Vars...
    var notificationsAllowed = true

    //MARK: - Views's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    //MARK: - Function...
    func setupViews(){
        getUserData()
        view.bringSubviewToFront(notificationsSwitch)
        notificationsSwitch.set(width: 30, height: 18)
    }
    
    //MARK: - Actions...
    
    @IBAction func backBtnAction(_ sender: UIButton){
        popViewController()
    }
    
    @IBAction func switchAction(_ sender: UISwitch){
        
        if sender.isOn {
            turnOnNotifications(foodieId: Auth.auth().currentUser?.uid ?? "")
        } else {
            turnOffNotifications(foodieId: Auth.auth().currentUser?.uid ?? "")
        }
    }

}

//MARK: - Network Layers...

extension NotificationSettingsVC {
    
    
    ///turnOffNotifications...
    func turnOffNotifications(foodieId: String){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(foodieId).setData(["notificationsAllowed": false], merge: true) { (err) in
            if let err = err {
                RappleActivityIndicatorView.stopAnimation()
                debugPrint("Error adding document: \(err)")
            } else {
               
                self.notificationsSwitch.isOn = false
                self.notificationsOnOffLbl.text = "Turn On Notifications"
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///turnOnNotifications...
    func turnOnNotifications(foodieId: String){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(foodieId).setData(["notificationsAllowed": true], merge: true) { (err) in
            if let err = err {
                RappleActivityIndicatorView.stopAnimation()
                debugPrint("Error adding document: \(err)")
            } else {
                
                self.notificationsSwitch.isOn = true
                self.notificationsOnOffLbl.text = "Turn Off Notifications"
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///getUserData...
    func getUserData(){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {
                Alert.showMsg(msg: "error getting user's data")
                RappleActivityIndicatorView.stopAnimation()
            }
            else {
                guard let myData = snapShot!.data(), let myUser = FoodieUserModel(dictionary: myData) else {
                    return
                }
                if myUser.notificationsAllowed == true {
                    RappleActivityIndicatorView.stopAnimation()
                    self.notificationsSwitch.isOn = true
                    self.notificationsOnOffLbl.text = "Turn Off Notifications"
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    self.notificationsSwitch.isOn = false
                    self.notificationsOnOffLbl.text = "Turn On Notifications"
                }
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
}
