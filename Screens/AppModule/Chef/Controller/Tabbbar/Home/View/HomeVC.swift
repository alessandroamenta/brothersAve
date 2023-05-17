//
//  HomeVC.swift
//  Food App
//
//  Created by Syed Saood Ul Hasnain on 28/09/2021.
//

import UIKit
import MapKit
import Quickblox
import FirebaseAuth
import FirebaseAuth
import FirebaseFirestore
import SystemConfiguration
import RappleProgressHUD

class HomeVC: UIViewController{
    
    // MARK: - IBOutlets
    @IBOutlet var categoryView: [UIView]!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    
    // MARK: - Variables
    var currentChef = ChefService.instance.chefUser
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Supporting Functions
    ///setupViews...
    func setupViews(){
        // self.tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
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
                appCredentials.chefId = myUser.id
                appCredentials.name = myUser.name
                appCredentials.chefId = myUser.id
                appCredentials.email = myUser.email
                //self.profileImage.sd_setImage(with: URL(string: myUser.profilePic))
                self.profileImage.sd_setImage(with: URL(string: myUser.profilePic), placeholderImage: UIImage(named: "user"), options: .forceTransition)
                self.lblName.text = "Hi \(myUser.name)!"
                
                self.setTapGesureOnView()
                if Auth.auth().currentUser != nil {
                    let pushManager = PushNotificationManager(userID: Auth.auth().currentUser!.uid)
                    pushManager.registerForPushNotifications()
                }
            }
        }
        connectUserWithChatServer()
    }
    
    func connectUserWithChatServer(){
        
        if appCredentials.isSocialPlatfrom == true {
            let userID = QBSession.current.currentUserID
            let Password = UserDefaults.standard.object(forKey: "Password") as? String ?? ""
            QBChat.instance.connect(withUserID: userID, password: Password, completion: { (error) in
                if error != nil {
                    RappleActivityIndicatorView.stopAnimation()
                    print("not connected to chat")
                    
                }
                else { RappleActivityIndicatorView.stopAnimation(); print("Connected...")  }
            })
        } else {
            let userID = QBSession.current.currentUserID
            let Password = Constants.appCredentials.password ?? ""
            QBChat.instance.connect(withUserID: userID, password: Password, completion: { (error) in
                if error != nil {
                    RappleActivityIndicatorView.stopAnimation()
                    print("not connected to chat")
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    print("Connected...")
                }
            })
        }
    }
    
    func setTapGesureOnView(){
        var index = 0
        categoryView.forEach { views in
            let tapgest = UITapGestureRecognizer(target: self, action: #selector(handleTappedView(sender:)))
            views.addGestureRecognizer(tapgest)
            views.tag = index
            index = index + 1
        }
    }
    
    @objc func handleTappedView(sender: UITapGestureRecognizer){
        
        switch sender.view?.tag {
        case 0:
            let controller: AddFoodSectionVC = AddFoodSectionVC.initiateFrom(Storybaord: .chef)
            controller.category = "Foods"
            self.pushViewController(viewController: controller)
        case 1:
            let controller: AddRecipeSectionVC = AddRecipeSectionVC.initiateFrom(Storybaord: .chef)
            controller.category = "Recipe"
            self.pushViewController(viewController: controller)
        default:
            let controller: AddLessonsVC1 = AddLessonsVC1.initiateFrom(Storybaord: .chef)
            self.pushViewController(viewController: controller)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func btnRequestTapped(_ sender: Any){
        
        let controller: AllBuyerRequestVC = AllBuyerRequestVC.initiateFrom(Storybaord: .chef)
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func btnOrderTrackTapped(_ sender: Any){

        let controller: YourOrderVC = YourOrderVC.initiateFrom(Storybaord: .foodie)
        controller.fieldName = "chefId"
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func btnCoursesTapped(_ sender: Any){
        
        let controller: YourLessonsVC = YourLessonsVC.initiateFrom(Storybaord: .chef)
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func btnPaymentTapped(_ sender: Any){
        let controller: PaymentsVC = PaymentsVC.initiateFrom(Storybaord: .chef)
        self.pushViewController(viewController: controller)
    }
    
}
