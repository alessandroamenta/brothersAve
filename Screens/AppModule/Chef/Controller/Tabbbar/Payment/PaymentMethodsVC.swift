//
//  PaymentMethodsVC.swift
//  Food App
//
//  Created by HF on 12/12/2022.
//

import UIKit
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore

class PaymentMethodsVC: UIViewController {

    // MARK: - IBOutlets...
    @IBOutlet weak var cardNumberField:UITextField!
    @IBOutlet weak var expiryDateField:UITextField!
    @IBOutlet weak var cvvCodeField:UITextField!
    
    // MARK: - Variables...
    
    //MARK: - View's Lifecycle...
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions...

    ///handleAddCardBtnActoion...
    func handleAddCardBtnActoion(){
        if cardNumberField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter card number") }
        else if expiryDateField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter expiry date") }
        else if cvvCodeField.isEmptyTextField() { presentAlert(withTitle: "Alert", message: "Enter cvc") }
        else {
            let expiryMonth = expiryDateField.text!.prefix(2), expiryYear = expiryDateField.text!.suffix(2)
            createPaymentMethod(cardNumber: cardNumberField.text!, expiryMonth: "\(expiryMonth)", expiryYear: "\(expiryYear)", cvc: cvvCodeField.text!)
        }
    }
    
    // MARK: - Actions...
    @IBAction func backBtnAction(_ sender:UIButton){
        popViewController()
    }

    @IBAction func addCardBtnAction(_ sender:UIButton){
        handleAddCardBtnActoion()
    }
}

//MARK: - Networking Layers...
extension PaymentMethodsVC {
    
    ///createPaymentMethod...
    func createPaymentMethod(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String){
        RappleActivityIndicatorView.startAnimating()
        constants.servicesManager.createPaymentMethod(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc) { result in
            switch result {
            case .success(let response):
                print(response)
                if response.status == "ok" {
                    guard let customerId = appCredentials.customerStripeId, let pmId = response.paymentMethod?.id else { RappleActivityIndicatorView.stopAnimation(); return }
                    print("payment id",pmId)
                   self.saveCardIntoStripe(customerId: customerId, pmId: pmId)
                }
                else {
                    
                    RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "try again") }
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: error)
            }
        }
    }
    
    func saveCardIntoStripe(customerId: String, pmId: String){
        constants.servicesManager.saveCardIntoStripe(customerId: customerId, pmId: pmId) { resultent in
            switch resultent {
                
            case .success(let response):
                print(response)
                if response.status == "ok" {
                    print(response)
                    self.presentAlertAndDismissToPreviousView(withTitle: "Alert", message: "Card added successfully", controller: self)
                    self.clearData()
                    RappleActivityIndicatorView.stopAnimation()
                }
                else {
                    RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "please try again") }
            case .failure(_): RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "please try again")
            }
        }
    }
    
    func clearData(){
        self.cardNumberField.text = ""
        self.expiryDateField.text = ""
        self.cvvCodeField.text = ""
    }
    
}

//MARK:- UITextFieldDelegate...
extension PaymentMethodsVC: UITextFieldDelegate {
    
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



