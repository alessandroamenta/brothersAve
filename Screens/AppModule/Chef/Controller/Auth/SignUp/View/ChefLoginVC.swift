//
//  LoginVC.swift
//  Food App
//
//  Created by Chirp Technologies on 27/09/2021.
//

import UIKit
import Firebase
import Quickblox
import CryptoKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseMessaging
import RappleProgressHUD
import FirebaseFirestore
import AuthenticationServices


class ChefLoginVC: UIViewController, FUIAuthDelegate {
    
    //MARK: - Controller Life Cycle
    
    fileprivate var currentNonce: String?
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var passwordViewBtn:UIButton!
    
    var newUser = QBUUser()
    var userQBID : UInt?
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var customerId = ""
    var connectAccountId : String?
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Supporting Functions
    
    
    func handleLoginNow(){
        RappleActivityIndicatorView.startAnimating()
        let email = txtFieldEmail.text!; let password = txtFieldPassword.text!
        UserDefaults.standard.set(password, forKey: "Password")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in // check for errors
            if error != nil {
                if email != result?.user.email { RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "User doesn't exist") }
                else {RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: "Invalid email or password")}
            }
            else {
                print("Login Successfully.....")
                QBRequest.logIn(withUserLogin: email, password: password) { response, user in
                    if response.isSuccess {
                        ChefService.instance.getUserOfChefUser(userID: Auth.auth().currentUser?.uid ?? "") { success, chef in
                            if success{
                                if chef?.role == "Chef"{
                                    self.updateUserFCM()
                                    RappleActivityIndicatorView.stopAnimation()
                                    ChefService.instance.setCurrentUser(chef: chef!)
                                    UserDefaults.standard.set("Chef", forKey: "userRole")
                                    let controller: TabbarVC = TabbarVC.initiateFrom(Storybaord: .chef)
                                    self.setNewRootViewController(storyboard: "Chef", identifier: "TabbarVC")
                                    self.pushViewController(viewController: controller)
                                    
                                }else{
                                    RappleActivityIndicatorView.stopAnimation()
                                    Alert.showMsg(msg: "Your Role does not match this profile please enter other one")
                                }
                            }
                            else{
                                RappleActivityIndicatorView.stopAnimation()
                                Alert.showMsg(msg: "error getting Chef user")
                            }
                        }
                        
                    } else {
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlert(withTitle: "Alert", message: "Error in login with Quickblox")
                    }
                }
            }
        }
    }
    
    //google sign in
    func googleAuthentication() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print("Error:\(error)")
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            RappleActivityIndicatorView.startAnimating()
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error:\(error)")
                    self.presentAlert(withTitle: "Alert", message: "\(error)")
                    RappleActivityIndicatorView.stopAnimation()
                } else if result != nil {
                    
                    let username = result?.user.displayName
                    let email = result?.user.email
                    let id = result?.user.uid ?? ""
                    let imageUrl = result?.user.photoURL
                    print("Actual id", id)
                    appCredentials.uid = id
                    appCredentials.name = username
                    appCredentials.email = email
                    let string = id
                    let lowerCasedPassword = string.lowercased()
                    print("Divided Id",lowerCasedPassword)
                    constants.appCredentials.password = lowerCasedPassword
                    constants.appCredentials.imageURL = imageUrl?.absoluteString
                    self.checkIsUserAlreadyRegisteredOrNot()
                }
            }
        }
    }
    
    ///updateUserFCM...
    func updateUserFCM(){
        guard let token = Messaging.messaging().fcmToken else { print("FMC NOT GETTING OR READY YET.....");  return}
        ChefService.instance.updateUserFCM(fcm: token)
    }
    
    //MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any){
        popViewController()
    }
    
    @IBAction func passwordViewBtnAction(_ sender: UIButton){
        if txtFieldPassword.isSecureTextEntry {
            txtFieldPassword.isSecureTextEntry = false
            passwordViewBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            passwordViewBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            txtFieldPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func forgotPassworTapped(_ sender: UIButton){
        pushViewController(storyboard: "Chef", identifier: "ForgotPassword")
    }
    
    @IBAction func logInBtnPressed(_ sender: Any) {
        if txtFieldEmail.isEmptyTextField() {presentAlert(withTitle: "Alert", message: "Please enter your email")}
        else if txtFieldPassword.isEmptyTextField() {presentAlert(withTitle: "Alert", message: "Please enter your password")}
        else {handleLoginNow()}
    }
    
    @IBAction func btnDontHaveAccountTapped(_ sender: Any){
        let controller: ChefSignUpVC = ChefSignUpVC.initiateFrom(Storybaord: .chef)
        pushViewController(viewController: controller)
        
    }
    
    @IBAction func termsAndConditionBtnTapped(_ sender: UIButton){
        openLinkWith(urlLink: "https://www.google.com")
    }
    
    
    @IBAction func applebtnPressed(_ sender: Any) {
        handleAppleLogin()
        
    }
    
    @IBAction func googlebtnPressed(_ sender: Any) {
        googleAuthentication()
    }
    
}

//MARK: - Network Layers...

extension ChefLoginVC {
    
    ///createStripeUser...
    func createStripeUser(name: String, email: String){
        constants.servicesManager.createStripeUser(email: email, name: name) { resultent in
            switch resultent {
            case .success(let response):
               print("create Stripe Account Response",response)
                appCredentials.customerStripeId = response.data
                self.customerId = response.data ?? ""
                print("Customer Id",response.data as Any)
                let userData = ChefUserModel(id: appCredentials.uid ?? "", QBID: self.userQBID!, name: appCredentials.name ?? "", email: appCredentials.email ?? "", role: "Chef", instagramLink: "", tikTokLink: "", profilePic: Constants.appCredentials.imageURL ?? "", address: "", zipcode: "", courses: [String](), isRequirement: true, achevements: [String](), background: [String](), cusine: [String](), experties: [String](), buyerRequests: [String](), lat: 0.0, long: 0.0, journey: "", fcmToken: Constants.appCredentials.fcmToken ?? "", cookingIds: [String](), contactList: [String](), customerId: response.data ?? "", pendingClearence: 0.0, connectedAccountId: "", isAccountVarified: false, rating: 0.0)
                self.updateUserFCM()
                ChefService.instance.chefUser = userData
                self.updateUserDataNow(userData: userData)
                RappleActivityIndicatorView.stopAnimation()
                
            case .failure(let error): RappleActivityIndicatorView.stopAnimation()
                print("create Stripe Account",error)
            }
        }
    }
    
    ///updateUserDataNow...
    func updateUserDataNow(userData: ChefUserModel) {
        ChefService.instance.setUserData(userData: userData) { resultent in
            switch resultent {
            case .success(let response): print(response); RappleActivityIndicatorView.stopAnimation()
                let controller: TellUSVC = TellUSVC.initiateFrom(Storybaord: .chef)
                controller.chefModel = userData
                UserDefaults.standard.set("Chef", forKey: "userRole")
                self.pushViewController(viewController: controller)
            case .failure(let error): print(error); RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Error", message: "Error saving user's data")
            }
        }
    }
    
    ///handleAppleLogin...
    func handleAppleLogin(){
        self.LoginWithApple { resultent in
            switch resultent {
            case .success(let response):
                appCredentials.uid = response.user.uid
                appCredentials.email = response.user.email;
                constants.appCredentials.imageURL = response.user.photoURL?.absoluteString ?? ""
                self.checkIsUserAlreadyRegisteredOrNot()
            case .failure(let error): RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: error)
            }
        }
    }
    
    ///checkIsUserAlreadyRegisteredOrNot...
    func checkIsUserAlreadyRegisteredOrNot(){
        RappleActivityIndicatorView.startAnimating()
        appCredentials.isSocialPlatfrom = false
        ChefService.instance.checkIsUserAlreadyRegisteredOrNot { isRegistered in
            if isRegistered {
                
                Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapshot, error in
                    if error != nil {
                        RappleActivityIndicatorView.stopAnimation()
                        Alert.showMsg(msg: error?.localizedDescription ?? "")
                    } else {
                        guard let data = snapshot?.data() else {return}
                        let role = data["role"] as? String ?? ""
                        if role == "Chef" {
                            QBRequest.logIn(withUserEmail: appCredentials.email!, password: constants.appCredentials.password!) { response, user in
                                if response.isSuccess {
                                    self.updateUserFCM()
                                    UserDefaults.standard.set("Chef", forKey: "userRole")
                                    let controller: TabbarVC = TabbarVC.initiateFrom(Storybaord: .chef)
                                    self.setNewRootViewController(storyboard: "Chef", identifier: "TabbarVC")
                                    self.pushViewController(viewController: controller)
                                    RappleActivityIndicatorView.stopAnimation()
                                    
                                } else {
                                    RappleActivityIndicatorView.stopAnimation()
                                    self.presentAlert(withTitle: "Alert", message: "Error in login with Quickblox")
                                }
                            }
                        } else {
                            RappleActivityIndicatorView.stopAnimation()
                            Alert.showMsg(msg: "Your role does not match this profile select other account")
                        }
                    }
                }
            }
            else {
                let email = appCredentials.email
                let password = constants.appCredentials.password
                self.newUser.email = email
                self.newUser.password = password
                
                DispatchQueue.main.async {
                    ///signUp With Quickblox...
                    QBRequest.signUp(self.newUser, successBlock: { response, user in
                        self.userQBID = user.id;
                        /// login with quickblox...
                        QBRequest.logIn(withUserEmail: appCredentials.email!, password: constants.appCredentials.password!, successBlock: { (response, user) in
                            ///createWithPostMan
                            self.createStripeUser(name: appCredentials.name ?? "", email: appCredentials.email ?? "")
                            
                        }, errorBlock: { (response) in
                            RappleActivityIndicatorView.stopAnimation()
                            self.presentAlert(withTitle: "Alert", message: "Error in login with Quickblox")
                        })
                    }, errorBlock: { (response) in
                        RappleActivityIndicatorView.stopAnimation()
                        self.presentAlert(withTitle: "Alert", message: "something went wrong")
                    })
                }
            }
        }
    }
}

//MARK: - Extensios
extension ChefLoginVC : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    ///LoginWithApple...
    @available(iOS 13.0, *)
    func LoginWithApple(complection: @escaping (APIResult<AuthDataResult>)-> Void) {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    ///randomNonceString...
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = "";var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0; let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess { fatalError( "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)") }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count { result.append(charset[Int(random)]); remainingLength -= 1 }
            }
        }
        return result
    }
    
    ///sha256...
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    ///presentationAnchor...
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    ///authorizationController...
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            
            appCredentials.name = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
            
            // initialize with firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (AuthDataResult, error) in
                if let user = AuthDataResult?.user {
                    appCredentials.uid = user.uid
                    let string = user.uid
                    let myStringArr = string.components(separatedBy: " ")
                    let password = myStringArr[0]
                    let lowerCasedPassword = password.lowercased()
                    constants.appCredentials.password = lowerCasedPassword
                    appCredentials.email = user.email;
                    constants.appCredentials.imageURL = user.photoURL?.absoluteString ?? ""
                    self.checkIsUserAlreadyRegisteredOrNot()
                }
            }
        }
    }
    
    ///didCompleteWithError...
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        RappleActivityIndicatorView.stopAnimation()
    }
    
}





