//
//  NetworkModels.swift
//  Food App
//
//  Created by HF on 30/12/2022.
//

import UIKit


// MARK: - UserRegistration

///StripeConnectAccountResponse...
struct StripeConnectAccountResponse: Codable {
    let status : String?
    let error : String?
    let account : connectedAccountResponse?
    
    enum CodinkKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case account = "account"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        account = try values.decodeIfPresent(connectedAccountResponse.self, forKey: .account)
        error = try values.decode(String.self, forKey: .error)
    }
}

///connectedAccountResponse...
struct connectedAccountResponse: Codable {
    let id : String?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        id = try value.decodeIfPresent(String.self, forKey: .id)
    }
}

///StripeCreateCardTokenResponse...
struct StripeCreateCardTokenResponse: Codable {
    let status : String?
    let error : String?
    let token : CreateCardTokenResponse?
    
    enum CodinkKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case account = "token"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        token = try values.decodeIfPresent(CreateCardTokenResponse.self, forKey: .token)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

///CreateCardTokenResponse...
struct CreateCardTokenResponse: Codable {
    let id : String?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        id = try value.decodeIfPresent(String.self, forKey: .id)
    }
}

///StripeUserRegistrationResponse...
struct StripeUpdateAccountResponse : Codable {
    let status : String?
    let error : String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case error = "error"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

///StripeUserRegistrationResponse...
struct StripeUserRegistrationResponse : Codable {
    let status : String?
    let error : String?
    let data : String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case data = "customerId"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        data = try values.decodeIfPresent(String.self, forKey: .data)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

///StripeCardPaymentMethodResponse...
struct StripeCardPaymentMethodResponse : Codable {
    let status : String?
    let paymentMethod : PaymentMethodResponse?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case paymentMethod = "paymentMethod"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        paymentMethod = try values.decodeIfPresent(PaymentMethodResponse.self, forKey: .paymentMethod)
    }
}

///PaymentMethodResponse...
struct PaymentMethodResponse : Codable {
    let id : String?
    let card: Card?

    enum CodingKeys: String, CodingKey { case id = "id"; case card = "card" }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        card = try values.decodeIfPresent(Card.self, forKey: .card)
    }
}

struct Card : Codable {
    let brand : String?
    let last4: String?

    enum CodingKeys: String, CodingKey { case brand = "brand"; case last4 = "last4" }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brand = try values.decodeIfPresent(String.self, forKey: .brand)
        last4 = try values.decodeIfPresent(String.self, forKey: .last4)
    }
}


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

///APIBaseResponse...
struct APIBaseResponse : Codable {
    let status : String?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }
}


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


///CardsListPaymentMethodResponse...
struct CardsListPaymentMethodResponse : Codable {
    let status : String?
    let error : String?
    let paymentMethod : [PaymentMethodResponse]?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case paymentMethod = "paymentMethods"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        paymentMethod = try values.decodeIfPresent([PaymentMethodResponse].self, forKey: .paymentMethod)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

// MARK: -

struct NotificationResponse : Codable {
    let multicast_id : Int?
    let failure : Int?
    let success : Int?

    enum CodingKeys: String, CodingKey {

        case multicast_id = "multicast_id"
        case failure = "failure"
        case success = "success"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        multicast_id = try values.decodeIfPresent(Int.self, forKey: .multicast_id)
        failure = try values.decodeIfPresent(Int.self, forKey: .failure)
        success = try values.decodeIfPresent(Int.self, forKey: .success)
    }

}




///StripeUserRegistrationResponse...
struct StripeConnectBaseResponse : Codable {
    let status : String?
    let error : String?
    let account : StripeConnectAccount?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case account = "account"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        account = try values.decodeIfPresent(StripeConnectAccount.self, forKey: .account)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

///StripeConnectAccount...
struct StripeConnectAccount : Codable {
    let id : String?
    let external_account: external_accounts?
    let capabilitie: Account_Capabilities?
    let requirements: requirementsModel?
     
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case external_account = "external_accounts"
        case capabilitie = "capabilities"
        case requirements = "requirements"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        external_account = try values.decodeIfPresent(external_accounts.self, forKey: .external_account)
        capabilitie = try values.decodeIfPresent(Account_Capabilities.self, forKey: .capabilitie)
        requirements = try values.decodeIfPresent(requirementsModel.self, forKey: .requirements)
        
    }
}


///requirementsModel...
struct requirementsModel : Codable {
    let errors : [errorsModel]?
    let alternatives: [String]?
    let currently_due: [String]?
    let eventually_due: [String]?
    let past_due: [String]?
    let pending_verification: [String]?
    
     
    enum CodingKeys: String, CodingKey {
        case errors = "errors"
        case alternatives = "alternatives"
        case currently_due = "currently_due"
        case eventually_due = "eventually_due"
        case past_due = "past_due"
        case pending_verification = "pending_verification"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        errors = try values.decodeIfPresent([errorsModel].self, forKey: .errors)
        alternatives = try values.decodeIfPresent([String].self, forKey: .alternatives)
        currently_due = try values.decodeIfPresent([String].self, forKey: .currently_due)
        eventually_due = try values.decodeIfPresent([String].self, forKey: .eventually_due)
        past_due = try values.decodeIfPresent([String].self, forKey: .past_due)
        pending_verification = try values.decodeIfPresent([String].self, forKey: .pending_verification)
    }
}

///errorsModel...
struct errorsModel : Codable {
    let code : String?
     
    enum CodingKeys: String, CodingKey {
        case code = "code"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(String.self, forKey: .code)
    }
}

  
///Account_Capabilities...
struct Account_Capabilities : Codable {
    let transfers : String?
     
    enum CodingKeys: String, CodingKey {
        case transfers = "transfers"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        transfers = try values.decodeIfPresent(String.self, forKey: .transfers)
    }
}


///external_accounts...
struct external_accounts : Codable {
    let total_count : Int?
     
    enum CodingKeys: String, CodingKey {
        case total_count = "total_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total_count = try values.decodeIfPresent(Int.self, forKey: .total_count)
    }
}



//MARK: - AccountLinkBaseResponse...
struct AccountLinkBaseResponse : Codable {
    let status : String?
    let error : String?
    let accountLink : accountLinkResponse?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case error = "error"
        case accountLink = "accountLink"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        accountLink = try values.decodeIfPresent(accountLinkResponse.self, forKey: .accountLink)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}

///accountLink...
struct accountLinkResponse : Codable {
    let url : String?
     
    enum CodingKeys: String, CodingKey {
        case url = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }
}

///BaseResponse...
struct BaseResponse: Codable {
    let status: String?
    let error : String?
    enum CodingKeys: String, CodingKey { case status = "status"; case error = "error" }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
}
