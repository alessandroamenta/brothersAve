//
//  ForgotPassword.swift
//  Food App
//
//  Created by HF on 10/01/2023.
//

import UIKit
import Quickblox
import FirebaseAuth
import RappleProgressHUD

class ForgotPassword: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Functions
    
    ///passwordResetwithQuickbloxAndFirebase...
    func passwordResetwithQuickbloxAndFirebase() {
        RappleActivityIndicatorView.startAnimating()
        let email = emailField.text ?? ""
        QBRequest.resetUserPassword(withEmail: email, successBlock: { (response:QBResponse) in
            print("Mail sent with QuickBlox")
            self.ResetPasswordWithFirebase()
        }, errorBlock: { (error:QBResponse) in
            RappleActivityIndicatorView.stopAnimation()
            Alert.showMsg(msg: error.description)
            print("QuickBlox password reset error :", error)
        })
    }
    
    ///ResetPasswordWithFirebase...
    func ResetPasswordWithFirebase() {
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: emailField.text!) { error in
            if let _ = error {RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "User deosn't exist") }
            else {RappleActivityIndicatorView.stopAnimation();self.presentAlert(withTitle: "Alert", message: "Email sent"); self.emailField.text = "" }
        }
    }
    
    // MARK: - Actions...
    @IBAction func backBtnAction(_ sender: Any) {
        popViewController()
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        if emailField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter Email") }
        else if !emailField.isValidEmail() { presentAlert(withTitle: "Alert", message: "Enter the valid email address") }
        else {
            ///passwordResetwithQuickbloxAndFirebase()
        }
    }
}
