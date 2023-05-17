//
//  PaymentsVC.swift
//  Food App
//
//  Created by HF on 06/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RappleProgressHUD

class PaymentsVC: UIViewController {

    //MARK: - Properties

    @IBOutlet weak var amountLbl:UILabel!
    @IBOutlet weak var withdrawBtn:UIButton!
    @IBOutlet weak var accountVerifiedLbl:UILabel!
    
    //MARK: - Vars...
    var selectIndex = 0
    fileprivate var withDrawData: StripeConnectBaseResponse?
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Supporting Functions
    func setupViews(){
        getAccountId()
    }
    
    //MARK: - Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        self.popViewController()
    }
    
    @IBAction func addCardBtnTapped(_ sender:UIButton){
        pushViewController(storyboard: "Chef", identifier: "CreateCardVC")
    }
    
    @IBAction func withdrawBtnAction(_ sender:UIButton){
        handleWithDrawAction()
    }
}

//MARK: - NetworkLayers...
extension PaymentsVC {
    
    ///getAccountId...
    func getAccountId(){
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
                self.amountLbl.text = "\(myUser.pendingClearence)"
                if myUser.isAccountVarified == true {
                    self.accountVerifiedLbl.textColor = UIColor.green
                    self.accountVerifiedLbl.text = "Acount Verified"
                    self.withdrawBtn.setTitle(title: "Withdraw Now")
                } else {
                    self.accountVerifiedLbl.textColor = UIColor.red
                    self.accountVerifiedLbl.text = "Account Unverified"
                    self.withdrawBtn.setTitle(title: "Create Card/Verify Account")
                }
                appCredentials.connectedAccountId = myUser.connectedAccountId
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///handleWithDrawAction...
       func handleWithDrawAction(){
           print(appCredentials.connectedAccountId ?? "not updated")
           
           if appCredentials.connectedAccountId == "" { ///check if user stripre connect account is not created...
               self.createStripeConnectAccountNow(email: appCredentials.email ?? "")
           }
           else {
               self.retrivedStripeConnectAccountDetailNow(accountId: appCredentials.connectedAccountId ?? "")
           }
       }
    
    
    ///createStripeConnectAccountNow
    func createStripeConnectAccountNow(email: String){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.createStripeConnectAccount(email: email) { resultent in
            switch resultent {
                
            case .success(let response):
                print(response)
                if response.status == "ok" { /// if user account created then
                    guard let id = response.account?.id else {
                        
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlert(withTitle: "Alert", message: Constants.errorMsg); return }
                    appCredentials.connectedAccountId = id
                    self.withDrawData = response; self.updateUserWithDrawID(id: id)
                }
                else {
                    RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: response.error ?? "") }
                
            case .failure(_): RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: Constants.errorMsg)
            }
        }
    }
    
    //updateUserWithDrawID...
    func updateUserWithDrawID(id: String){
        ChefService.instance.updateUserWithDrawID(id: id) { resultent in
            switch resultent {
            case .success(let response): print(response); appCredentials.connectedAccountId = id
                
                guard let data = self.withDrawData else {
                    RappleActivityIndicatorView.stopAnimation()
                    self.presentAlert(withTitle: "Alert", message: Constants.errorMsg) ; return }
                
                if (data.account?.external_account?.total_count ?? 0) != 0 {///check card is attached or not... If Attached then...
                    
                    if data.account?.capabilitie?.transfers == "inactive" { /// check is card linked or not if not then...
                        self.createLinkForAccountNow(accountId: appCredentials.connectedAccountId ?? "")
                    }
                    else { ///if card is not linked then show Go To WebView Url...
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlert(withTitle: "Alert", message: "Your Account is Already verified. Go to admin panel for withdraw")
                    }
                }
                else { /// if card is not attached then show card View to get card details...
                    RappleActivityIndicatorView.stopAnimation()
                    self.presentAlertAndGoToViewController(withTitle: "Alert",message: "Please add your card first", storyboardName: "Chef", idetifier: "CreateCardVC")
                    
                }
            case .failure(let error):
                print(error); RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: error)
            }
        }
    }
    
    ///createLinkForAccountNow...
    func createLinkForAccountNow(accountId: String){
        constants.servicesManager.createLinkForAccountNow(accountId: accountId) { resultent in
            switch resultent {
                
            case .success(let response):
                print(response)
                if response.status == "ok" {
                     
                    let okAction = UIAlertAction(title: "Go to link", style: .default) { action in
                        self.openLinkWith(urlLink: response.accountLink?.url ?? "www.google.com"); RappleActivityIndicatorView.stopAnimation()
                    }
                    let cancelAction = UIAlertAction(title: "No", style: .default) { action in  RappleActivityIndicatorView.stopAnimation()} ;  RappleActivityIndicatorView.stopAnimation()
                    
                    self.presentAlertAndGotoThatFunctionWithCancelBtnAction(withTitle: "Alert", message: "You will be redirected to link to verify your stripe account details", OKAction: okAction, secondBtnTitle: "No", secondBtnAction: cancelAction)
                     
                }
                else { RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: response.error ?? "") }
                
            case .failure(let errorMsg):
                print(errorMsg)
                RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: Constants.errorMsg)
            }
        }
    }
    
    
    ///createStripeConnectAccountNow
    func retrivedStripeConnectAccountDetailNow(accountId: String){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.retrivedStripeConnectAccountDetails(accountid: accountId) { resultent in
            switch resultent {
                
            case .success(let response): print(response)
                if response.status == "ok" { /// if user account created then
                    ///
                    if (response.account?.external_account?.total_count ?? 0) != 0 { ///check card is attached or not... If Attached then...
 
                        if response.account?.requirements?.pending_verification?.count != 0  {
                            RappleActivityIndicatorView.stopAnimation()
                            self.presentAlert(withTitle: "Alert", message: "Please wait your account approval is pending.")
                        }
                        else {
                            if response.account?.capabilitie?.transfers == "inactive" ||
                                response.account?.requirements?.errors?.count != 0 ||
                                response.account?.requirements?.alternatives?.count != 0 ||
                                response.account?.requirements?.currently_due?.count != 0 ||
                                response.account?.requirements?.eventually_due?.count != 0 ||
                                response.account?.requirements?.past_due?.count != 0 ||
                                response.account?.requirements?.pending_verification?.count != 0  { /// check is card linked or not if not then...
                                self.accountVerifiedLbl.textColor = UIColor.red
                                self.accountVerifiedLbl.text = "Account Unverified!"
                                self.createLinkForAccountNow(accountId: appCredentials.connectedAccountId ?? "")
                            }
                            else { ///if card is not linked then show Go To WebView Url...
                                self.updateUserWidthDrawVerifaction(value: true)
                                
                            }
                        }
                        
                    }
                    else { /// if card is not attached then show card View to get card details...
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlertAndGoToViewController(withTitle: "Alert",message: "Please add your card first", storyboardName: "Chef", idetifier: "CreateCardVC")
                    }
                }
                else { RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: response.error ?? "") }
                
            case .failure(let errorMsg):
                print(errorMsg);
                RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "errorMsg")
            }
        }
    }
    
    func updateUserWidthDrawVerifaction(value: Bool){
        ChefService.instance.updateUserWithDrawVerfication(value: value) { resultent in
            switch resultent {
                
            case .success(_):
                self.accountVerifiedLbl.textColor = UIColor.green
                self.accountVerifiedLbl.text = "Account Verified!"
                self.withdrawBtn.setTitle("Withdraw Now", for: .normal)
                RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "Your Account is verified.")
                
            case .failure(_):
                self.accountVerifiedLbl.textColor = UIColor.red
                self.accountVerifiedLbl.text = "Account Unverified!"
                self.withdrawBtn.setTitle("Create Card/Verify Account", for: .normal)
                RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: Constants.errorMsg)
            }
        }
    }
}



