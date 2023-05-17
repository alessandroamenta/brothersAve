//
//  Utlis.swift
//  HealthySmily
//
//  Created by Zaid's MacBook on 31/01/2021.
//  Copyright © 2021 Zablesoft. All rights reserved.
//

import UIKit
//

import Foundation
import SystemConfiguration

class Utils {
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isPhoneNumberValid(phoneNumber: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: phoneNumber)
        return result
    }
    
    
    
    static func toHourAndMinute(minutes: Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    static func getDay(from string: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        guard let date = formatter.date(from: string) else { return -1 }
        guard let day = Calendar.current.dateComponents([.day], from: date).day else { return -1 }
        
        return day
    }
    
    static func getReadableDateFormate(from string: String, formate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = formatter.date(from: string) else { return "" }
        
        formatter.dateFormat = formate
        formatter.timeZone = TimeZone.current
        
        let readableDate = formatter.string(from: date)
    
        return readableDate
    }
    
    static func getReadableDateFromTimestamp(stringDate: String) -> String? {
//        let date = Date(timeIntervalSince1970: timeStamp)
//        let dateFormatter = DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: stringDate) else { return "" }
        
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if dateFallsInCurrentWeek(date: date) {
            if Calendar.current.isDateInToday(date) {
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: date)
            } else {
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: date)
            }
        } else {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    static func dateFallsInCurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == datesWeek)
    }
    
    static func serverToLocal(date:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.date(from: date)

        return localDate
    }
    
    static func getMaxCount<T>(array1: [T], array2: [T], array3: [T]) -> [T] {
        let array1Count = array1.count
        let array2Count = array2.count
        let array3Count = array3.count
        
        let maxCount = max(max(array1Count, array2Count), array3Count)
        if maxCount == array1Count {
            return array1
        } else if maxCount == array2Count {
            return array2
        } else {
            return array3
        }
    }
    
    static func hourToHoursAndMinutes(minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        
        return String(hour) + " h " + String(minute) + " m"
    }
    
    static func roundToPlaces(double: Double,places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(double * divisor) / divisor
    }
    
    static func getTimeZone() -> String {
        return TimeZone.current.identifier
    }
    // MARK: Internet Connectivity Checking
     static func isConnectedToNetwork() -> Bool {

          var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
          zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
          zeroAddress.sin_family = sa_family_t(AF_INET)

          let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
              $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                  SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
              }
          }

          var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
          if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
              return false
          }

          /* Only Working for WIFI
          let isReachable = flags == .reachable
          let needsConnection = flags == .connectionRequired

          return isReachable && !needsConnection
          */

          // Working for Cellular and WIFI
          let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
          let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
          let ret = (isReachable && !needsConnection)

          return ret

      }

}


