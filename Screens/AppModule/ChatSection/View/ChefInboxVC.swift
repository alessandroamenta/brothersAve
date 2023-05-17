//
//  ChefInboxVC.swift
//  Food App
//
//  Created by HF on 05/12/2022.
//

import UIKit
import Photos
import Quickblox
import SDWebImage
import FirebaseAuth
import YPImagePicker
import FirebaseFirestore
import RappleProgressHUD

class ChefInboxVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var MessageTableView:UITableView!
    @IBOutlet weak var messageText:UITextView!
    
    // MARK: - Variables
    var messages : [MessagesModel] = []
    let chatDialog = QBChatDialog(dialogID: nil, type: .private)
    var config = YPImagePickerConfiguration()
    var selectedImagesFromGallary: [UIImage] = []
    var currentUser = ChefService.instance.chefUser
    var imageURL : String = ""
    var receiverId : UInt = 0
    var messageID : String = ""
    var foodieId = ""
    var friend : FoodieUserModel?
    var current_user_QBID : UInt = 0
    var myImage = ""
    var foodieQBID : UInt?
    var foodieImage = ""
    var foodiFcm = ""
    var notificationsAllowed : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Functions
    
    ///setupView...
    func setupView(){
        
        QBChat.instance.addDelegate(self)
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {  }
            else {
                guard let myData = snapShot!.data(), let myUser = ChefUserModel(dictionary: myData) else {
                    return
                }
                self.current_user_QBID = myUser.QBID
                self.myImage = myUser.profilePic
            }
        }
        
        Firestore.firestore().collection("users").document(foodieId).getDocument { snapShot, error in
            if error != nil {  }
            else {
                guard let foodieData = snapShot!.data(), let foodie = FoodieUserModel(dictionary: foodieData) else {
                    return
                }
                self.notificationsAllowed = foodie.notificationsAllowed
                self.foodiFcm = foodie.fcmToken
                self.foodieQBID = foodie.QBID
                self.foodieImage = foodie.profilePic
                self.createDialog(id: NSNumber(value: foodie.QBID))
                self.MessageTableView.reloadData()
                
            }
        }
        MessageTableView.register(UINib(nibName: "ChefMessagesCell", bundle: nil), forCellReuseIdentifier: "ChefMessagesCell")
        configurationYpPicker()
    }
    
    ///configurationYpPicker...
    func configurationYpPicker(){
        
        config.isScrollToChangeModesEnabled = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "Images , Video"
        config.screens = [.photo,.library, .video]
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.maxCameraZoomFactor = 1.0
        config.library.maxNumberOfItems = 1
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.defaultMultipleSelection = false
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = true
    }
    
    ///loadMessages...
    func loadMessages(dialogeId: String) {
        
        let page = QBResponsePage(limit: 0, skip: 0)
        let extendedRequest = ["sort_asc":"date_sent","mark_as_read":"0"]
        QBRequest.messages(withDialogID: dialogeId, extendedRequest: extendedRequest, for: page) { [self] response, messages, page in
            if response.isSuccess {
                if messages.count > 0 {
                    for message in messages {
                        
                        if message.attachments?.first != nil {
                            if message.senderID == foodieQBID {
                                self.receiverId = message.senderID
                            }
                            let attachment = message.attachments?.first
                            let URL = attachment!.url
                            print("Loaded File :" ,URL as Any)
                            let date = message.dateSent
                            let dateformatter = DateFormatter()
                            dateformatter.timeStyle = .short
                            dateformatter.dateStyle = .short
                            let time = dateformatter.string(from: date!)
                            let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: URL, sentTimeDate: time)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.MessageTableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                RappleActivityIndicatorView.stopAnimation()
                            }
                            
                        } else {
                            if message.senderID == foodieQBID {
                                self.receiverId = message.senderID
                            }
                            let date = message.dateSent
                            let dateformatter = DateFormatter()
                            dateformatter.timeStyle = .short
                            dateformatter.dateStyle = .short
                            let time = dateformatter.string(from: date!)
                            let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: "", sentTimeDate: time)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.MessageTableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                RappleActivityIndicatorView.stopAnimation()
                            }
                        }
                    }
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                }
            } else {
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    ///createDialog...
    func createDialog(id: NSNumber) {
        RappleActivityIndicatorView.startAnimating()
        chatDialog.occupantIDs = [id]
        QBRequest.createDialog(chatDialog) { response, createdDialog in
            if response.isSuccess {
                self.loadMessages(dialogeId: createdDialog.id!)
            } else {
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///didTapForImage...
    func didTapForProfileImage(){
        
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.selectedImagesFromGallary.removeAll()
                self.selectedImagesFromGallary.append(photo.image)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    ///sendMessageWithAttachment...
    func sendMessageWithAttachment(selectedImage : UIImage){
        RappleActivityIndicatorView.startAnimating()
        guard let image = selectedImage as? UIImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        QBRequest.tUploadFile(uploadData, fileName: "myImage", contentType: "image/png", isPublic: true, successBlock: { (response, uploadedBlob) in
            let attachment = QBChatAttachment()
            attachment.id = uploadedBlob.uid
            attachment.name = uploadedBlob.name
            //for image
            attachment.type = "image"
            attachment.url = uploadedBlob.privateUrl()
            self.imageURL = attachment.url!
            print("Uploaded file URL :", self.imageURL)
            let message = QBChatMessage()
            message.customParameters["save_to_history"] = true
            message.text = self.messageText.text ?? ""
            //Set attachment
            message.attachments = [attachment]
            //Send message with attachment
            self.chatDialog.send(message, completionBlock:
                                    { error in
                if let error = error {
                    RappleActivityIndicatorView.stopAnimation()
                    print(error)
                } else {
                    if message.senderID == self.foodieQBID {
                        self.receiverId = message.senderID
                    }
                    let date = message.dateSent
                    let dateformatter = DateFormatter()
                    dateformatter.timeStyle = .short
                    dateformatter.dateStyle = .short
                    let time = dateformatter.string(from: date!)
                    self.messageID = message.id!
                    let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: self.imageURL, sentTimeDate: time)
                    self.messages.append(newMessage)
                    //self.sendPushNotificxation()
                    if self.notificationsAllowed == true {
                        self.sendSingleNotification(title: "Food App", message: "Message from \(appCredentials.name ?? "Someone"): \(self.messageText.text!)", receiverToken: self.foodiFcm)
                    } else {
                        print("this user has turned off his notifications")
                    }
                    
                    self.updateContactList(chefId: self.foodieId)
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.MessageTableView.reloadData()
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        self.messageText.text = ""
                        self.selectedImagesFromGallary.removeAll()
                    }
                    
                }
            }
                                 
            )}, statusBlock: { (request, status)  in
                //Update UI with upload progress
                let progress = CGFloat(status.percentOfCompletion)
                print("Upload Progress", progress)
            }, errorBlock: { (response) in
                //show upload error
            })
        
    }
    
    ///sendTextMessage...
    func sendTextMessage(){
        RappleActivityIndicatorView.startAnimating()
        let message = QBChatMessage()
        message.customParameters["save_to_history"] = true
        message.text = self.messageText.text ?? ""
        self.chatDialog.send(message) { (error) in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                print(error as Any)
            } else {
                if message.senderID == self.foodieQBID {
                    self.receiverId = message.senderID
                }
                let date = message.dateSent
                let dateformatter = DateFormatter()
                dateformatter.timeStyle = .short
                dateformatter.dateStyle = .short
                let time = dateformatter.string(from: date!)
                self.messageID = message.id!
                let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: "", sentTimeDate: time)
                self.messages.append(newMessage)
                
                if self.notificationsAllowed == true {
                    self.sendSingleNotification(title: "Food App", message: "Message from \(appCredentials.name ?? "Someone"): \(self.messageText.text!)", receiverToken: self.foodiFcm)
                } else {
                    print("this user has turned off his notifications")
                }
                self.updateContactList(chefId: self.foodieId)
                DispatchQueue.main.async {
                    RappleActivityIndicatorView.stopAnimation()
                    self.MessageTableView.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    self.messageText.text = ""
                }
            }
        }
    }
    
    ///sendPushNotificxation...
    func sendPushNotificxation(){
        
        let event = QBMEvent()
        event.notificationType = .push
        let receiverID = self.foodieQBID
        let senderID = self.current_user_QBID
        print("Receiver id In Push :", receiverID as Any)
        print("senderID id In Push :", senderID)
        event.usersIDs = "\(String(describing: receiverID))"
        event.type = .oneShot
        var pushParameters = [String : String]()
        pushParameters["message"] = self.messageText.text!
        pushParameters["ios_badge"] = "2"
        pushParameters["ios_sound"] = "app_sound.wav"
        // custom params
        let thread_id = NSUUID().uuidString
        print("Msg Id in Push:",self.messageID)
        pushParameters["thread_likes"] = "24"
        pushParameters["thread_id"] =  thread_id
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: pushParameters, options: .prettyPrinted) {
            let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8)
            event.message = jsonString
            print("Push Json String :",jsonString as Any)
        }
        QBRequest.createEvent(event, successBlock: {(response, events) in
            print("Events in Push ", events as Any)
        }, errorBlock: {(response) in
            
        })
    }
    
    
    // MARK: - Actions...
    
    @IBAction func backBtnAction(_ sender: UIButton){
        popViewController()
    }
    
    @IBAction func linksBtnAction(_ sender:UIButton){
        didTapForProfileImage()
    }
    
    @IBAction func sendBtnAction(_ sender:UIButton){
        
        if messageText.text == "" && selectedImagesFromGallary.count <= 0 { presentAlert(withTitle: "Alert", message: "Please enter message text or select an Image") }
        else {
            if selectedImagesFromGallary.count <= 0 {
                sendTextMessage()
            } else {
                if messageText.text == "" { presentAlert(withTitle: "Alert", message: "Please enter some text")
                    
                } else {
                    self.sendMessageWithAttachment(selectedImage: self.selectedImagesFromGallary[0])
                }
            }
        }
    }
}

//MARK: - Tablewview delegate and Datasource methods...
extension ChefInboxVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = MessageTableView.dequeueReusableCell(withIdentifier: "ChefMessagesCell", for: indexPath) as! ChefMessagesCell
        let message = messages[indexPath.row]
        
        if message.senderId == self.current_user_QBID {
            
            cell.leftView.isHidden = true; cell.rightView.isHidden = false
            cell.messageRightLbl.text = message.message; cell.messageRightLbl.isHidden = false; cell.messageLeftLbl.isHidden = true
            cell.dateRightLbl.isHidden = false; cell.dateRightLbl.text = message.sentTimeDate;cell.dateLeftLbl.isHidden = true
            if message.imageURL == "" {
                cell.heighConstarint.constant = 0
                cell.leftHeighConstarint.constant = 0
                cell.leftImage.isHidden = true
                cell.rightImage.isHidden = true
            } else {
                cell.heighConstarint.constant = 200
                cell.leftHeighConstarint.constant = 0
                cell.leftImage.isHidden = true
                cell.rightImage.isHidden = false
                cell.rightImage.sd_setImage(with: URL(string: message.imageURL!))
            }
            cell.leftUserImage.isHidden = true
            cell.rightUserImage.isHidden = false
            cell.rightUserImage.sd_setImage(with: URL(string: self.myImage))
        } else {
            
            cell.leftView.isHidden = false; cell.rightView.isHidden = true
            cell.messageLeftLbl.text = message.message; cell.messageLeftLbl.isHidden = false; cell.messageRightLbl.isHidden = true
            cell.dateRightLbl.isHidden = true; cell.dateLeftLbl.text = message.sentTimeDate;cell.dateLeftLbl.isHidden = false
            if message.imageURL == "" {
                cell.heighConstarint.constant = 0
                cell.leftHeighConstarint.constant = 0
                cell.leftImage.isHidden = true
                cell.rightImage.isHidden = true
            } else {
                cell.heighConstarint.constant = 0
                cell.leftHeighConstarint.constant = 200
                cell.leftImage.isHidden = false
                cell.rightImage.isHidden = true
                cell.leftImage.sd_setImage(with: URL(string: message.imageURL!))
            }
            cell.leftUserImage.isHidden = false
            cell.rightUserImage.isHidden = true
            cell.leftUserImage.sd_setImage(with: URL(string: (foodieImage)))
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        cell.selectedBackgroundView = bgView
        return cell
    }
}

//MARK: - Chat delegate methods...
extension ChefInboxVC: QBChatDelegate {
    
    // MARK: - Manage chat receive message callback's
    func chatDidReceive(_ message: QBChatMessage) {
        
        if message.attachments?.first != nil {
            if message.senderID == self.foodieQBID {
                self.receiverId = message.senderID
            }
            let attachment = message.attachments?.first
            let URL = attachment!.url
            print("Loaded File :" ,URL as Any)
            let date = message.dateSent
            let dateformatter = DateFormatter()
            dateformatter.timeStyle = .short
            dateformatter.dateStyle = .short
            let time = dateformatter.string(from: date!)
            let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: URL, sentTimeDate: time)
            self.messages.append(newMessage)
            DispatchQueue.main.async {
                RappleActivityIndicatorView.stopAnimation()
                self.MessageTableView.reloadData()
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
        } else {
            if message.senderID == self.foodieQBID {
                self.receiverId = message.senderID
            }
            let date = message.dateSent
            let dateformatter = DateFormatter()
            dateformatter.timeStyle = .short
            dateformatter.dateStyle = .short
            let time = dateformatter.string(from: date!)
            let newMessage = MessagesModel(senderId: message.senderID, receiverId: self.receiverId, message: message.text!, imageURL: "", sentTimeDate: time)
            self.messages.append(newMessage)
            DispatchQueue.main.async {
                RappleActivityIndicatorView.stopAnimation()
                self.MessageTableView.reloadData()
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.MessageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
}

//MARK: - Network Layers...
extension ChefInboxVC {
    ///updateContactList...
    func updateContactList(chefId : String){
        
        ChefService.instance.updateContactList(userId: chefId) { resultent in
            switch resultent {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    ///sendSingleNotification...
    func sendSingleNotification(title: String, message: String, receiverToken: String){
        constants.servicesManager.sendSingleleNotification(title: title, message: message, receiverToken: receiverToken, completion: { resultent in
            switch resultent {
            case .success(let response):
                if response.failure == 0 {RappleActivityIndicatorView.stopAnimation();print(response.failure ?? 0)} else {RappleActivityIndicatorView.stopAnimation();print(response.success ?? 0)}
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        })
    }
}



