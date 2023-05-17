//
//  ProfileVC.swift
//  Food App
//
//  Created by Muneeb Zain on 04/10/2021.
//

import UIKit
import Quickblox
import SDWebImage
import TagListView
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore
import FTPopOverMenu_Swift

class ChefProfileVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCertificate1: UILabel!
    @IBOutlet weak var lblCertificate2: UILabel!
    @IBOutlet weak var lblJounrey: UITextView!
    @IBOutlet weak var experienceLbl:UILabel!
    @IBOutlet weak var logOutBtn:UIButton!
    @IBOutlet weak var backBtn:UIButton!
    
    //MARK: - Vars...
    var signoutId : String?
    var searchedId = ""
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchedId == "" {
            backBtn.isHidden = true
            setCurrentChefData()
        } else {
            backBtn.isHidden = false
            setSearchedChefProfile()
        }
        lblJounrey.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }

    //MARK: - Supporting Functions
    
    ///clearUserData...
    func clearUserData(){
        appCredentials.pendingClearence = 0
        appCredentials.customerStripeId = ""
        appCredentials.email = ""
        appCredentials.name = ""
        appCredentials.paypal = ""
        appCredentials.connectedAccountId = ""
        appCredentials.chefId = ""
        UserDefaults.standard.removeObject(forKey: "Password")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "userRole")
    }
    
    ///signOut...
    func signOut(){
        RappleActivityIndicatorView.startAnimating()
        QBRequest.logOut(successBlock: { (response) in
            try! Auth.auth().signOut()
            self.clearUserData()
            //self.popTo(ViewController: WelcomeVC.self)
            self.setNewRootViewController(storyboard: "Welcome", identifier: "WelcomeVC")
            
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
        
    ///setSearchedChefProfile...
    func setSearchedChefProfile(){
        Firestore.firestore().collection("users").document(searchedId).getDocument { snapShot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "error getting use's data")
            }
            else {
                guard let myData = snapShot!.data(), let myUser = ChefUserModel(dictionary: myData) else {
                    return
                }
                self.signoutId = myUser.id
                self.profileImgView.sd_setImage(with: URL(string: myUser.profilePic), placeholderImage: UIImage(systemName: "person.circle.fill"), options: .forceTransition)
                self.lblName.text = myUser.name
                self.experienceLbl.text = "\(myUser.name)'s Bio & experience"
                if myUser.achevements.count == 2 {
                    self.lblCertificate1.text = "1. \(myUser.achevements[0])"
                    self.lblCertificate2.text = "2. \(myUser.achevements[1])"
                        }
                self.lblJounrey.text = myUser.journey
                        self.tagListView.textFont = UIFont.systemFont(ofSize: 20)
                        self.tagListView.alignment = .left // possible values are [.leading, .trailing, .left, .center, .right]
                let arrayOfTags = (myUser.cusine) + (myUser.background) + (myUser.experties)
                        self.tagListView.addTags(arrayOfTags)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///setCurrentChefData...
    func setCurrentChefData(){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(appCredentials.chefId ?? "").getDocument { snapShot, error in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "error getting use's data")
            }
            else {
                guard let myData = snapShot!.data(), let myUser = ChefUserModel(dictionary: myData) else {
                    return
                }
                self.signoutId = myUser.id
                self.profileImgView.sd_setImage(with: URL(string: myUser.profilePic), placeholderImage: UIImage(named: "user"), options: .forceTransition)
                self.lblName.text = myUser.name
                self.experienceLbl.text = "\(myUser.name)'s Bio & experience"
                if myUser.achevements.count == 2 {
                    self.lblCertificate1.text = "1. \(myUser.achevements[0])"
                    self.lblCertificate2.text = "2. \(myUser.achevements[1])"
                        }
                self.lblJounrey.text = myUser.journey
                        self.tagListView.textFont = UIFont.systemFont(ofSize: 20)
                        self.tagListView.alignment = .left // possible values are [.leading, .trailing, .left, .center, .right]
                let arrayOfTags = (myUser.cusine) + (myUser.background) + (myUser.experties)
                        self.tagListView.addTags(arrayOfTags)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
        
    //MARK: - Actions
    @IBAction func backBtnTapped(_ sender:UIButton){
        
        self.dismiss(animated: true)
    }
    
    @IBAction func btnMenuTapped(_ sender: UIButton){
        FTPopOverMenu.showForSender(sender: sender,with: ["Log out"], done: { (selectedIndex) in

            Alert.showWithTwoActions(title: "Confirm", msg: "Are you sure want to Logout?", okBtnTitle: "Yes", okBtnAction: {
                if Auth.auth().currentUser?.uid != appCredentials.chefId {
                    Alert.showMsg(msg: "You can't logout from this user")
                } else {
                    self.signOut()
                }
                
            }, cancelBtnTitle: "Cancel") {
            }
        },cancel: {
            print("cancel")
        })
    }
    
}
