//
//  NetworkManager.swift
//  Food App
//
//  Created by HF on 27/12/2022.
//
import Moya
import UIKit
import Alamofire

//let url = "https://food-app-payment.herokuapp.com/v1"

//MARK:- Services Provider
struct ServicesProvider { static let provider = MoyaProvider<NetworkServices>() }

//MARK:- ServicesManager
struct ServicesManager {
    
    ///connectStripeAccount...
    func connectStripeAccount(email: String, completion: @escaping (APIResult<StripeConnectAccountResponse>)-> Void){
        ServicesProvider.provider.request(.connectStripeAccount(email: email)) { result in
            switch result {
            case .success(let respone):
                do {
                    let result = try JSONDecoder().decode(StripeConnectAccountResponse.self, from: respone.data)
                    completion(.success(result))
                }
                catch let error {completion(.failure(error.localizedDescription))}
            case .failure(let error): completion(.failure(error.localizedDescription))
            }
        }
    }
    
    ///createStripeUser...
    func createStripeUser(email: String, name: String, completion: @escaping (APIResult<StripeUserRegistrationResponse>) -> Void) {
        
        ServicesProvider.provider.request(.createUserIntoStripe(name: name, email: email)) { (resultent) in
            switch resultent {
                
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(StripeUserRegistrationResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    
    ///createPaymentMethod...
    func createPaymentMethod(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String, completion: @escaping (APIResult<StripeCardPaymentMethodResponse>) -> Void) {
        
        ServicesProvider.provider.request(.createPaymentMethod(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc)) { (resultent) in
            switch resultent {
                
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(StripeCardPaymentMethodResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    ///createPaymentMethod...
    func createCardToken(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String, completion: @escaping (APIResult<StripeCreateCardTokenResponse>) -> Void) {
        
        ServicesProvider.provider.request(.createCardToken(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc)) { (resultent) in
            switch resultent {
                
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(StripeCreateCardTokenResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    ///stripeUpdateAccount...
    func stripeUpdateAccount(tokenId: String, connectedAccountId: String, completion: @escaping (APIResult<StripeUpdateAccountResponse>)-> Void ){
        
        ServicesProvider.provider.request(.updateAccount(tokenId: tokenId, ConnectedAccountId: connectedAccountId)) { result in
            switch result {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(StripeUpdateAccountResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case . failure(let error):
                completion(.failure(error.localizedDescription))
            }
        }
    }
    
    ///saveCardIntoStripe...
    func saveCardIntoStripe(customerId: String, pmId: String, completion: @escaping (APIResult<APIBaseResponse>) -> Void) {
        
        ServicesProvider.provider.request(.saveCardIntoStripe(customerId: customerId, pmId: pmId)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(APIBaseResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    ///getAllStripeCards...
    func getAllStripeCards( customerId: String, completion: @escaping (APIResult<CardsListPaymentMethodResponse>) -> Void) {

        ServicesProvider.provider.request(.getAllStripeCards(customerId: customerId)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(CardsListPaymentMethodResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    ///deletePaymentCard...
    func deletePaymentCard( pmid: String, completion: @escaping (APIResult<APIBaseResponse>) -> Void) {
        ServicesProvider.provider.request(.deletePaymentCard(pmid: pmid)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(APIBaseResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    
    ///chargeStripeAmountNow...
    func chargeStripeAmountNow(customerId: String, paymentMethodId: String, amount: Double, completion: @escaping (APIResult<APIBaseResponse>) -> Void) {
        ServicesProvider.provider.request(.chargeStripeAmountNow(customerId: customerId, paymentMethodId: paymentMethodId, amount: amount)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(APIBaseResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    
    func sendMultipleNotifications(title: String, message: String, receiverToken: [String], completion: @escaping (APIResult<NotificationResponse>) -> Void){
        print(receiverToken)
        ServicesProvider.provider.request(.sendMultiple(title: title, message: message, receiverToken: receiverToken)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    print(response)
                    let result = try JSONDecoder().decode(NotificationResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error {
                    print(error)
                    completion(.failure(error.localizedDescription))  }
            case .failure(let error):
                print(error)
                completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    func sendSingleleNotification(title: String, message: String, receiverToken: String, completion: @escaping (APIResult<NotificationResponse>) -> Void){
        print(receiverToken)
        ServicesProvider.provider.request(.sendSingle(title: title, message: message, receiverToken: receiverToken)) { (resultent) in
            switch resultent {
            case .success(let response):
                do {
                    print(response)
                    let result = try JSONDecoder().decode(NotificationResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error {
                    print(error)
                    completion(.failure(error.localizedDescription))  }
            case .failure(let error):
                print(error)
                completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    
    //MARK: - Stripe Connect:-
     
     ///createConnectStripeUser...
     func createStripeConnectAccount(email: String, completion: @escaping (APIResult<StripeConnectBaseResponse>) -> Void) {
         ServicesProvider.provider.request(.createStripeConnectAccount(email: email)) { resultent in
             switch resultent {
                 
             case .success(let response):
                 do {
                     let result = try JSONDecoder().decode(StripeConnectBaseResponse.self, from: response.data)
                     completion(.success(result))
                 }
                 catch let error { completion(.failure(error.localizedDescription))  }
             case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
             }
         }
     }
    
    ///createLinkForAccountNow...
    func createLinkForAccountNow(accountId: String, completion: @escaping (APIResult<AccountLinkBaseResponse>) -> Void) {
        ServicesProvider.provider.request(.createLinkForAccountNow(accountid: accountId)) { resultent in
            switch resultent {
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(AccountLinkBaseResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
    ///retrivedStripeConnectAccountDetails...
    func retrivedStripeConnectAccountDetails(accountid: String, completion: @escaping (APIResult<StripeConnectBaseResponse>) -> Void) {
        ServicesProvider.provider.request(.retrivedStripeConnectAccountDetails(accountid: accountid)) { resultent in
            switch resultent {
                
            case .success(let response):
                do {
                    let result = try JSONDecoder().decode(StripeConnectBaseResponse.self, from: response.data)
                    completion(.success(result))
                }
                catch let error { completion(.failure(error.localizedDescription))  }
            case .failure(let error):  completion(.failure(error.errorDescription ?? ""))
            }
        }
    }
    
}

