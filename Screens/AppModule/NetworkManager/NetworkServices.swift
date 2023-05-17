//
//  NetworkServices.swift
//  Food App
//
//  Created by HF on 30/12/2022.
//

import UIKit
import Moya


//MARK: - NetworkServices...
enum NetworkServices {
    
    ///createUserIntoStripe...
    case connectStripeAccount(email: String)
    case createUserIntoStripe(name: String, email: String)
    case createPaymentMethod(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String)
    case saveCardIntoStripe(customerId: String, pmId: String)
    case getAllStripeCards(customerId: String)
    case chargeStripeAmountNow(customerId: String, paymentMethodId: String, amount: Double)
    case sendMultiple(title:String,message:String, receiverToken : [String])
    case sendSingle(title:String,message:String, receiverToken : String)
    case deletePaymentCard(pmid: String)
    case createCardToken(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String)
    case updateAccount(tokenId: String, ConnectedAccountId: String)
    case createStripeConnectAccount(email: String)
    case createLinkForAccountNow(accountid: String)
    case retrivedStripeConnectAccountDetails(accountid: String)
}


//MARK: - NetworkServices target type...
extension NetworkServices: TargetType {
    
    //MARK: - baseURL...
    var baseURL: URL {
        switch self {
            
        case .connectStripeAccount,.createUserIntoStripe, .createPaymentMethod, .saveCardIntoStripe, .getAllStripeCards, .chargeStripeAmountNow, .createCardToken, .updateAccount, .deletePaymentCard, .createStripeConnectAccount, .createLinkForAccountNow, .retrivedStripeConnectAccountDetails:
            return URL(string: constants.API.stripeBaseURL)!
            
        case .sendMultiple,.sendSingle:
            return URL(string: constants.API.firebaseFCMBaseURL)!
        }
    }
    
    //MARK: - path...
    var path: String {
        switch self {
        case .connectStripeAccount: return "connect/accounts"
        case .createUserIntoStripe: return "customer"
        case .createPaymentMethod: return "payment-method"
        case .saveCardIntoStripe: return "attach-card"
        case .getAllStripeCards: return "cards-list-v2"
        case .chargeStripeAmountNow: return "charges"
        case .sendMultiple: return "send"
        case .sendSingle: return "send"
        case .deletePaymentCard: return "payment-method"
        case .createCardToken: return "tokens/create_card"
        case .updateAccount: return "connect/accounts/attach_card"
        case .createStripeConnectAccount: return "connect/accounts"
        case .createLinkForAccountNow: return "connect/account_links"
        case .retrivedStripeConnectAccountDetails: return "connect/accounts"
        }
    }
    
    //MARK: - method...
    var method: Moya.Method {
        switch self {
        case .connectStripeAccount, .createUserIntoStripe, .createPaymentMethod, .saveCardIntoStripe, .getAllStripeCards, .chargeStripeAmountNow, .sendMultiple, .sendSingle, .createCardToken, .updateAccount, .createStripeConnectAccount, .createLinkForAccountNow :
            return .post
             
        case .deletePaymentCard: return .delete
            
        case .retrivedStripeConnectAccountDetails:
            return .get
        }
    }
    
    //MARK: - sampleData...
    var sampleData: Data { return Data() }
    
    //MARK: - task...
    var task: Task {
        switch self {
            ///connectStripeAccount...
        case .connectStripeAccount(let email):
            let parameter = ["email": email ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///createUserIntoStripe...
        case .createUserIntoStripe(let name, let email):
            let parameter = [ "name": name,
                              "email": email ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///createPaymentMethod...
        case .createPaymentMethod(cardNumber: let cardNumber, expiryMonth: let expiryMonth, expiryYear: let expiryYear, cvc: let cvc):
            let parameter = [ "cardNumber": cardNumber,
                              "expiryMonth": expiryMonth,
                              "expiryYear": expiryYear,
                              "cvc": cvc ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            
            ///saveCardIntoStripe...
        case .saveCardIntoStripe(customerId: let customerId, pmId: let pmId):
            let parameter = [ "customerId": customerId,
                              "pmId": pmId ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            
            ///getAllStripeCards...
        case .getAllStripeCards(customerId: let customerId):
            let parameter = [ "customer_id": customerId ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///chargeStripeAmountNow...
        case .chargeStripeAmountNow(customerId: let customerId, paymentMethodId: let paymentMethodId, amount: let amount):
            let parameter = [ "customerId": customerId,
                              "pmId": paymentMethodId,
                              "amount": amount * 1000 ] as [String : Any]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///sendMultiple...
        case .sendMultiple(title: let title, message: let message, receiverToken: let receiverToken):
            let parameter = ["registration_ids":receiverToken,
                             "notification":[ "title":title, "sound":"default", "body":message] ] as [String : Any]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///sendSingle...
        case .sendSingle(title: let title, message: let message, receiverToken: let receiverToken):
            let parameter = ["registration_ids": [receiverToken],
                             "notification":[ "title":title, "sound":"default", "body":message] ] as [String : Any]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///deletePaymentCard...
        case .deletePaymentCard(pmid: let pmid):
            let parameter = ["pmId": pmid]
            return .requestCompositeData(bodyData: sampleData, urlParameters: parameter)
            //return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///createCardToken...
        case .createCardToken(cardNumber: let cardNumber, expiryMonth: let expiryMonth, expiryYear: let expiryYear, cvc: let cvc):
            let parameter = [ "cardNumber": cardNumber,
                              "expiryMonth": expiryMonth,
                              "expiryYear": expiryYear,
                              "cvc": cvc ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///updateAccount...
        case .updateAccount(tokenId: let tokenId, ConnectedAccountId: let accountId):
            let parameter = ["external_account": tokenId,
                             "account": accountId ]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///createStripeConnectAccount...
        case .createStripeConnectAccount(email: let email):
            let parameter = ["email": email]
            return .requestCompositeData(bodyData: sampleData, urlParameters: parameter)
            
            ///createLinkForAccountNow...
        case .createLinkForAccountNow(accountid: let accountid):
            let parameter = ["account": accountid]
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
            ///retrivedStripeConnectAccountDetails...
        case .retrivedStripeConnectAccountDetails(accountid: let accountid):
            let parameter = [ "account": accountid ]
            return .requestCompositeData(bodyData: sampleData, urlParameters: parameter)
            
        }
    }
    
    //MARK: - headers...
    var headers: [String : String]? {
        switch self {
            
            ///Nil...
        case .connectStripeAccount, .createUserIntoStripe, .createPaymentMethod, .saveCardIntoStripe, .getAllStripeCards, .chargeStripeAmountNow, .createCardToken, .updateAccount, .deletePaymentCard, .createStripeConnectAccount, .createLinkForAccountNow, .retrivedStripeConnectAccountDetails:
            return nil
            
            ///Authorization...
        case .sendMultiple, .sendSingle:
            return ["Authorization": "key=" + constants.API.firebaseSficrectKey ]
        }
    }
    
    
}
