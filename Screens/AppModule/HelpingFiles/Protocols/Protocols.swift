//
//  Protocols.swift
//  House_Mingle
//
//  Created by HF on 07/09/2022.
//

import Foundation

protocol DocumentSerializable  {
    init?( dictionary:[String: Any] )
}

enum APIBaseResult {
    case success(String)
    case failure(String)
    
    var value: String? {
        switch self {
            case .success(let value): return value
            case .failure: return nil
        }
    }
}

///APIResult...
enum APIResult<T> {
    case success(T)
    case failure(String)
    
    var value: T? {
        switch self {
            case .success(let value): return value
            case .failure: return nil
        }
    }
}

///APIResult...
enum FirebaseAPIResult<Bool> {
    case success(Bool)
    case failure(String)
    
    var value: Bool? {
        switch self {
            case .success(let value): return value
            case .failure: return nil
        }
    }
}


