//
//  CreateCardVC.swift
//  Food App
//
//  Created by HF on 05/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RappleProgressHUD

protocol GetTokenFromCard { func handleCardTokenId(id: String); func didTapOnCancelBtn() }

class CreateCardVC: UIViewController {

    // MARK: - IBOutlets...
    @IBOutlet weak var cardNumberField:UITextField!
    @IBOutlet weak var expiryDateField:UITextField!
    @IBOutlet weak var cvvCodeField:UITextField!

    // MARK: - Variables...
    var delegateForToken: GetTokenFromCard?
    
    
    //MARK: - View's Lifecycle...
    override func viewDidLoad() {
        super.viewDidLoad()
        getAccountId()
    }
    
    // MARK: - Functions...

    ///handleAddCardBtnActoion...
    func handleAddCardBtnActoion(){
        if cardNumberField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter card number") }
        else if expiryDateField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter expiry date") }
        else if cvvCodeField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter cvc") }
        else {
            let expiryMonth = expiryDateField.text!.prefix(2), expiryYear = expiryDateField.text!.suffix(2)
            createCardToken(cardNumber: cardNumberField.text!, expiryMonth: "\(expiryMonth)", expiryYear: "\(expiryYear)", cvc: cvvCodeField.text!)
        }
    }
    
    // MARK: - Actions...
    @IBAction func backBtnAction(_ sender:UIButton){
        popViewController()
    }

    @IBAction func createBtnAction(_ sender:UIButton){
        handleAddCardBtnActoion()
    }

}

//MARK: - Networking Layers...
extension CreateCardVC {
    
    ///createCardToken...
    func createCardToken(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.createCardToken(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc) { resultent in
            switch resultent {
            case .success(let response):
                print("create card token response",response)
                if response.status == "ok"{
                    self.handleCardTokenId(id: response.token?.id ?? "")
                    RappleActivityIndicatorView.stopAnimation()
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: response.error ?? "")
                }
                
            case .failure(let error):
                Alert.showMsg(msg: error)
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
                print("create card toke error",error)
            }
        }
    }
    
    ///updateAccount...
    func updateAccount(connectedAccountId: String, tokenId: String){
        constants.servicesManager.stripeUpdateAccount(tokenId: tokenId, connectedAccountId: connectedAccountId) { resultent in
            switch resultent {
            case .success(let response):
                print("update account response",response)
                if response.status == "ok" {
                    self.clearData()
                    RappleActivityIndicatorView.stopAnimation()
                    
                    self.presentAlertAndBackToPreviousView(withTitle: "Alert", message: "Your Card Added Successfull", controller: self)
                    
                } else {
                
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: response.error ?? "")
                }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
                print("update account error",error)
            }
        }
    }
    
    ///clearData...
    func clearData(){
        self.cardNumberField.text = ""
        self.expiryDateField.text = ""
        self.cvvCodeField.text = ""
    }
    
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
                appCredentials.connectedAccountId = myUser.connectedAccountId
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
}

//MARK:- UITextFieldDelegate...
extension CreateCardVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        
        //cardNUmber...
        if textField == cardNumberField {
              
            ///Setup Back Space
            guard textField.text?.count ?? 0 < 19 else {
                let  char = string.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) { print("Backspace was pressed") ;return true }
                return false
            }
            
            //grouping tetfield text 4 digits and also set card type...
            textField.setText(to: currentText.grouping(every: 4, with: " "), preservingCursor: true)
            return false
        }
        ///Expiry Date...
        else if textField == expiryDateField {
            guard textField.text?.count ?? 0 < 5 else {
                let  char = string.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) { print("Backspace was pressed"); return true }
                return false
            }
            textField.setText(to: currentText.grouping(every: 2, with: "/"), preservingCursor: true)
            return false
        }
        ///CVV...
        else if textField == cvvCodeField {
            guard textField.text?.count ?? 0 < 4 else {
                let  char = string.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) { print("Backspace was pressed"); return true }
                return false
            }
        }
        return true
    }
}

extension CreateCardVC {
    ///handleCardTokenId...
    func handleCardTokenId(id: String) {
        self.updateAccount(connectedAccountId: appCredentials.connectedAccountId ?? "", tokenId: id)
    }
    
    func didTapOnCancelBtn() {
        RappleActivityIndicatorView.stopAnimation()
    }
}
