//
//  Constants.swift
//  House_Mingle
//
//  Created by HF on 08/09/2022.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseMessaging

let GID_KEY = FirebaseApp.app()?.options.clientID
var cityArr = [String]()
var teshilArr = [String]()
//var mouzaArr = [String]()
var kanalArr = ["0","1","2","3","4","5","6","7"]
var acreArr = [String]()

struct UsersConstant {
    static let perPage:UInt = 100
    static let noUsers = "No user with that name"
    static let subscriptionID = "last_voip_subscription_id"
    static let token = "last_voip_token"
    static let needUpdateToken = "last_voip_token_need_update"
    static let okAction = "Ok"
    static let noInternetCall = "Still in connecting state, please wait"
    static let noInternet = """
No Internet Connection
Make sure your device is connected to the internet
"""
}


struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToConference = "Enter to Video Chat"
    static let fullNameDidChange = "Full Name Did Change"
    static let login = "Login"
    static let checkInternet = "No Internet Connection"
    static let checkInternetMessage = "Make sure your device is connected to the internet"
    static let enterUsername = "Enter your login and display name"
    static let defaultPassword = "quickblox"
    static let signUp = "Signg up ..."
    static let intoVideoChat = "Login into Video Chat ..."
    static let withCurrentUser = "Login with current user ..."
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
}

struct ConstantStrings {
    static let networkErrorTitle = "Network error!"
    static let networkErrorMessage = "Such as timeout, interuppted connection or un reachable host has occured"
    static let verificationError = "Please enter 4 digits code."
    static let inValidOrEmailPhoneNo = "Your email/password or password is incorrect."
    static let inValidPhoneNo = "Your number is incorrect."
    static let inValidVerificationCode = "Your verification code is incorrect."
    static let selectDoctor = "Please select speciality of doctor."
    static let noDoctorFound = "No doctor found."
    static let errorGettingMembers = "Error in getting members, please try again later"
    static let errorInDeletingMembers = "Something went wrong in deleting user, please try again later."
    static let errorInUpdatingMembers = "Something went wrong in updating ptofile, please try again later."
    static let errorInRegistering = "Something went wrong while registering, please try again later."
    static let errorInLoadingMsg = "Something went wrong while loading messages, please try again later."
    static let errorInSendMsg = "Something went wrong while sending messages, please try again later."
    static let errorInBookingAppointment = "Something went wrong in booking appointment, please try again later"
    
    static let AppColor = "0192D2"
}


func getUniqueId()->String{
    let uid = UUID().uuidString.lowercased()
    return uid
}

func getCurrentDate() -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return (formatter.string(from: Date()))
}

func getCurrentTime() -> String{
    let currentDateTime = Date()
    let formatter = DateFormatter()
    
    formatter.timeStyle = .medium
    formatter.dateStyle = .none
    return (formatter.string(from: currentDateTime))
}

func getISODate() -> String{
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    print("ISO8601 string: \(isoDateFormatter.string(from: Date()))")
    return (isoDateFormatter.string(from: Date()))
    // dateTo: 2016-12-31 23:59:59 +0000
}

func getCurrentIntTime() -> Int{
    let time = Date().timeIntervalSince1970
    print(Int(time))
    return Int(time)
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func getCurrentPostTime() -> String{
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return (formatter.string(from: Date()))
}

func getCurrentPostDate() -> String{
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return (formatter.string(from: Date()))
}


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}

struct constants {
    
    private init() {}
        
    //MARK:- App static Variables
    static let strongPasswordMsg = "\nEnsure string has two uppercase letters\nEnsure string has one special character\nEnsure string has two digits\nEnsure string has two lowercase letters\nEnsure password length is 8"
    static let errorMsg = "Something went wrong please try again"
    static let HudLoadingMsg = "Loading..."
    static let socialLinksErrorMsg = "Address not valid"
    static let privacyPolicy = ""
    static let termsAndConditions = ""
    static let contactUs = ""
    static let servicesManager = ServicesManager()
    static let db = Firestore.firestore()
    static let storageRef =  Storage.storage().reference()
    static let dbWithCurrentUserPath = db.collection("Users").document(Auth.auth().currentUser?.uid ?? "")
    static let dbWithUsersPath = db.collection("Users")
    static let dbPathWithPosts = db.collection("FeedPosts")
    static let dbPathWithGroupPosts = db.collection("GroupPosts")
    static let dbPathWithGroups = db.collection("Groups")
    static let dbPathWithTalks = db.collection("Talks")
    static let userChargedAmount: Double = 5.50
    
    // MARK:- Static Colors
    struct Colors {
        static let mainHeadingTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let subHeadingTextColor = #colorLiteral(red: 0.3294117647, green: 0.3450980392, blue: 0.368627451, alpha: 1)
        static let primaryColor = #colorLiteral(red: 0.209341228, green: 0.5107113719, blue: 0.5459350944, alpha: 1)
        static let borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
    }
    
    // MARK: - App URLs
    struct API {
        static let stripeBaseURL = "https://food-app-payment.herokuapp.com/v1"
        static let googleMapGeoCodeBaseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        static let googleMapTextSearchBaseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        static let googleMapKey = "AIzaSyBL4JbKL4SotWhSAnoYflXy9fnHrmT52Lg"
        static let firebaseFCMBaseURL = "https://fcm.googleapis.com/fcm/"
        static let firebaseSficrectKey = "AAAABbFkORI:APA91bE6Jkp3PxR28DtF_KyLD-9jZe8lxS0JyKKgfTECuLT1jpLOCDbKQoAOeuMoX5lCe8EqxV7rkjF_VnIm_XkBuLoU0E3eiPHWlEh_AhpCxveqKz_nv5k3oLDOo-r25MInsFTkrB4p"
    }
    
    //MARK: - Apply Font
    static func applyFonts_NunitoText(style: FontStyle, size: CGFloat) -> UIFont {
        return UIFont(name: "Mulish-\(style.rawValue)", size: size)!
    }
    
    //MARK:- Font Styles
    enum FontStyle: String {
        case light = "Light"
        case regular = "Regular"
        case bold = "Bold"
        case semibold = "Semibold"
    }
    
    // MARK: - appCredentials...
    struct appCredentials {
        private init() {}
        
        static var password: String? {
            set { UserDefaults.standard.set(newValue, forKey: "password") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "password") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var imageURL: String? {
            set { UserDefaults.standard.set(newValue, forKey: "imageURL") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "imageURL") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var userUid: String? {
            set { UserDefaults.standard.set(newValue, forKey: "userUid") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "userUid") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var name: String? {
            set { UserDefaults.standard.set(newValue, forKey: "name") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "name") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        static var email: String? {
            set { UserDefaults.standard.set(newValue, forKey: "email") }
            get {
                if let getUid = UserDefaults.standard.string(forKey: "email") {
                    if getUid == "" { return "" }
                    let uid = getUid; return uid
                } else { return "" }
            }
        }
        
        ///isFirstTimeLunch...
        static var isFirstTimeLunch: Bool {
            set { UserDefaults.standard.set(newValue, forKey: "isFirstTimeLunch")}
            get {
                if UserDefaults.standard.object(forKey: "isFirstTimeLunch") == nil {
                    UserDefaults.standard.set(false, forKey: "isFirstTimeLunch"); return false
                }
                return UserDefaults.standard.bool(forKey: "isFirstTimeLunch")
            }
        }
        
        ///fcmToken...
        static var fcmToken: String? {
            set { UserDefaults.standard.set(newValue, forKey: "fcmToken") }
            get {
                if let fcm = UserDefaults.standard.string(forKey: "fcmToken") {
                    print(fcm)
                    if fcm == "" { if let token = Messaging.messaging().fcmToken { return token }; return "" }
                    let fcmId = fcm
                    return fcmId
                } else { return "" }
            }
        }
    }
}

protocol foodCategories: NSObject {
    func categoriePass(cat: String)
}

let TO_NOTIF_NTOFICATION_RECIEVED = Notification.Name("utifUserDataChanged")
typealias CompletionHandlerWithError = (_ Success: Bool,_ Error: Error?) -> ()
typealias CompletionHandler = (_ status:Bool, _ message:String?) -> ()

let TO_NOTIF_REACTION_CHANGED = Notification.Name("ReactionChanged")

//let headers: HTTPHeaders = [
//    "apikey": "18lFEyq2kgryn/6LrKnCPuMEB3MBntdBcKjXf2geSGM="
//]
let backgroundArr = ["Trained Cook","Community Foodie","Other","Traditional Food Maker","Chef","Homecooking"]
let cusineArr = ["Italian","Maxican","Thai","Indian","Japanese","Other"]
let expertiesArr = ["Pizza","Desserts","Vegan","Comfort Food","Other"]

let mediaPlaceHolder = UIImage(named: "mediaPlaceholder")
let userImgPlacholder = UIImage(named: "photo")

var placeHolderImage = UIImage(systemName: "person.circle.fill")

func getCurrentTime() -> Int{
    let time = Date().timeIntervalSince1970
    print(Int(time))
    return Int(time)
}

func getCurrentDateWithTime() -> String{
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return (formatter.string(from: Date()))
}

func getAgeFromDOF(date: String) -> (Int,Int,Int) {

    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "dd/MM/YYYY"
    let dateOfBirth = dateFormater.date(from: date)

    let calender = Calendar.current

    let dateComponent = calender.dateComponents([.year, .month, .day], from:
    dateOfBirth!, to: Date())

    return (dateComponent.year!, dateComponent.month!, dateComponent.day!)
}

protocol AddNewPaymentmethod { func handleNewPaymentMethod() }
// MARK: - CardSelectionDelegate...
protocol CardSelectionDelegate {
    func noCardsAvailable()
    func cardSelectedFromList(paymentMethod: PaymentMethodResponse)
}








