//
//  AddLessonsVC1.swift
//  Food App
//
//  Created by Chirp Technologies on 28/02/2022.
//

import UIKit
import FirebaseAuth
import CoreLocation
import YPImagePicker
import FirebaseFirestore
import RappleProgressHUD

class AddLessonsVC1: UIViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var txtFieldTitle: UITextField!
    @IBOutlet weak var lessonImage : UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var txtFieldDescription: UITextField!
    @IBOutlet weak var txtFieldDuration: UITextField!
    @IBOutlet weak var txtFieldTools: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var txtViewLocation: UITextView!
    @IBOutlet weak var txtFieldNoOfPeople: UITextField!
    @IBOutlet weak var txtViewLink: UITextView!
    @IBOutlet weak var txtViewCost: UITextField!
    @IBOutlet weak var txtViewAdditionalNotes: UITextView!
    
    //MARK: - Properties
    var type = "Online"
    var lat: Double?
    var long: Double?
    var selectedImagesFromGallary = [UIImage]()
    var isCommingForEdit: Bool = false
    var editData: LessonModel?
    var myFcm = ""
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Functions
    func setupViews(){
        getMyFcm()
        checkIfIsCommingForEditing()
        txtFieldNoOfPeople.delegate = self
        if segment.selectedSegmentIndex == 0 {
            stackView.isHidden = true
            stackView1.isHidden = false
        }
    }
    
    func checkIfIsCommingForEditing(){
        if isCommingForEdit {
            guard let data = editData else { return }
            if data.type == "Online" {
                txtFieldTitle.text = data.title
                lessonImage.sd_setImage(with: URL(string: data.image))
                imageBtn.setImage(nil, for: .normal)
                txtFieldDescription.text = data.description
                txtFieldDuration.text = String(data.duration)
                txtFieldTools.text = data.tools
                txtViewLink.text = data.link
                txtFieldNoOfPeople.text = String(data.numberOfPeople)
                txtViewAdditionalNotes.text = data.additionalNotes
            } else {
                txtFieldTitle.text = data.title
                lessonImage.sd_setImage(with: URL(string: data.image))
                imageBtn.setImage(nil, for: .normal)
                txtFieldDescription.text = data.description
                txtFieldDuration.text = String(data.duration)
                txtFieldTools.text = data.tools
                txtViewLocation.text = data.location
                txtFieldNoOfPeople.text = String(data.numberOfPeople)
                txtViewAdditionalNotes.text = data.additionalNotes
            }
        }
    }
    
    //MARK: - Supporting Files
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
    
    //MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl){
        if segment.selectedSegmentIndex == 0 {
            self.type = "Online"
            stackView.isHidden = true
            stackView1.isHidden = false
        }else{
            self.type = "Onsite"
            stackView.isHidden = false
            stackView1.isHidden = true
        }
    }
    
    @IBAction func imageBtnTapped(_ sender : Any) {
        didTapForLessonImage()
    }
    
    @IBAction func btnLocationTapped(_ sender: Any){
        if CLLocationManager().authorizationStatus == .authorizedWhenInUse || CLLocationManager().authorizationStatus ==  .authorizedAlways{
            let controller: LocationVC = LocationVC.initiateFrom(Storybaord: .foodie)
            controller.delegate = self
            self.pushViewController(viewController: controller)
        }
        else
        {
            print("Location services are not enabled")
            Alert.showWithTwoActions(title: "Location Enabled", msg: "Please go to Settings and turn on the permissions", okBtnTitle: "Setting", okBtnAction: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
                
            }, cancelBtnTitle: "Cancel") {
                print("Cancel")
            }
        }
    }
    
    @IBAction func btnCancelTapped(_ sender: Any){
        popViewController()
    }
    @IBAction func btnShareTapped(_ sender: Any){
        addFormValidations()
    }
}

extension AddLessonsVC1: DataPass {
    func dataPassing(searchedLocation: String, lat: Double, long: Double) {
        txtViewLocation.text = searchedLocation
        self.lat = lat
        self.long = long
        print(lat,long)
    }
}

//MARK: - Network Layers...
extension AddLessonsVC1 {
    
    ///getMyFcm...
    func getMyFcm(){
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
                self.myFcm = myUser.fcmToken
                print("my fcm", self.myFcm as String)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///didTapForLessonImage...
    func didTapForLessonImage(){
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.selectedImagesFromGallary.removeAll()
                self.selectedImagesFromGallary.append(photo.image)
                self.imageBtn.setImage(nil, for: .normal)
                self.lessonImage.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    ///getImageUrlString...
    func getImageUrlString(completion: @escaping (String)-> Void) {
        if selectedImagesFromGallary.count >= 1 {
            uploadImageToServer(completion: { url in completion(url) }) }
        else if selectedImagesFromGallary.count == 0 { completion("") }
    }
    
    ///randomString...
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    ///uploadServerImageToServer...
    func uploadImageToServer( completion: @escaping (String)-> Void) {
        let path = "chef_lesson_photo/\(randomString(length: 5)).jpg"
        guard let image = selectedImagesFromGallary.first else { completion(""); return }
        ChefService.instance.uploadImagesToServer(image: image, path: path) { resultent in
            switch resultent {
            case .success(let url): print(url); completion(url)
            case .failure(let error): print(error); completion("")
            }
        }
    }
    
    ///getFcmIdsAndSendNotifications...
    func getFcmIdsAndSendNotifications(lessonTitle:String){
        ChefService.instance.getAllFcmIDs { resultent in
            switch resultent {
            case .success(let fcmIds):
                var fcms = [String]()
                fcms = fcmIds
                print("fcms count before", fcms.count)
                fcms.removeAll { fcm in
                    if fcm == self.myFcm { return true } else { return false }
                }
                print("fcms count after", fcms.count)
                if fcms.count >= 1 {
                    
                    self.sendMultipleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has shared a lesson as '\(lessonTitle)' do check it!", receiverToken: fcms)
                }
                else { RappleActivityIndicatorView.stopAnimation();self.presentAlert(withTitle: "No One To Receive", message: "there's no one to receive") }
                
            case .failure(let error): print(error);RappleActivityIndicatorView.stopAnimation()
            }
        }
    }

    ///sendMultipleNotification...
    func sendMultipleNotification(title: String, message: String, receiverToken: [String]){
        constants.servicesManager.sendMultipleNotifications(title: title, message: message, receiverToken: receiverToken) { resultent in
            switch resultent {
            case .success(let response):
                if response.failure == 0 {RappleActivityIndicatorView.stopAnimation(); print(response.failure ?? 0) } else { RappleActivityIndicatorView.stopAnimation(); print(response.success ?? 0) }
            case .failure(let error): print(error);RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///addFormValidations...
    func addFormValidations(){
        
        if self.type == "Online" {

            if txtFieldTitle.text != "" && lessonImage.image != nil && txtFieldDescription.text != "" && txtFieldDuration.text != "" && txtFieldTools.text != "" && txtViewLink.text != "" && txtFieldNoOfPeople.text != "" {
                RappleActivityIndicatorView.startAnimating()
                getImageUrlString { imageUrl in
                    let date = Timestamp(date: Date())
                    let lesson = LessonModel(id: getUniqueId(), title: self.txtFieldTitle.text ?? "", description: self.txtFieldDescription.text ?? "", duration: Int(self.txtFieldDuration.text!) ?? 0, tools: self.txtFieldTools.text ?? "", type: self.type , location: "", lat: self.lat ?? 0, long: self.long ?? 0, numberOfPeople: Int(self.txtFieldNoOfPeople.text!) ?? 0, link: self.txtViewLink.text ?? "", additionalNotes: self.txtViewAdditionalNotes.text!, chefId: Auth.auth().currentUser?.uid ?? "", image: imageUrl, createdAt: date, cost: (self.txtViewCost.text)?.toDouble() ?? 0.0)
                    self.getFcmIdsAndSendNotifications(lessonTitle: self.txtFieldTitle.text!)
                    ChefService.instance.shareLesson(lesson: lesson)
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showWithCompletion(msg: "Your lesson has been uploaded successfully") {
                        self.popTo(ViewController: TabbarVC.self)
                    }
                }
                
            } else {
                Alert.showMsg(msg: "Please fill the missing requirement.")
            }
            
        } else {
            
            if txtFieldTitle.text != "" && lessonImage.image != nil && txtFieldDescription.text != "" && txtFieldDuration.text != "" && txtFieldTools.text != "" && txtFieldNoOfPeople.text != "" && txtViewLocation.text != "" {
                RappleActivityIndicatorView.startAnimating()
                getImageUrlString { imageUrl in
                    let date = Timestamp(date: Date())
                    let lesson = LessonModel(id: getUniqueId(), title: self.txtFieldTitle.text ?? "", description: self.txtFieldDescription.text ?? "", duration: Int(self.txtFieldDuration.text!) ?? 0, tools: self.txtFieldTools.text ?? "", type: self.type, location: self.txtViewLocation.text ?? "", lat: self.lat ?? 0, long: self.long ?? 0, numberOfPeople: Int(self.txtFieldNoOfPeople.text!) ?? 0, link: "", additionalNotes: self.txtViewAdditionalNotes.text!, chefId: Auth.auth().currentUser?.uid ?? "", image: imageUrl, createdAt: date, cost: (self.txtViewCost.text)?.toDouble() ?? 0.0)
                    self.getFcmIdsAndSendNotifications(lessonTitle: self.txtFieldTitle.text!)
                    ChefService.instance.shareLesson(lesson: lesson)
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showWithCompletion(msg: "Your lesson has been uploaded successfully") {
                        self.popTo(ViewController: TabbarVC.self)
                    }
                }
                
            } else {
                Alert.showMsg(msg: "Please fill the missing requirement.")
            }
        }
    }
}


