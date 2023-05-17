//
//  ChefConversationsList.swift
//  Food App
//
//  Created by HF on 12/12/2022.
//

import UIKit
import Quickblox
import SDWebImage
import FirebaseAuth
import FirebaseFirestore
import RappleProgressHUD

class ChefConversationsList: UIViewController {

    //MARK: - IBoutlets...
    @IBOutlet weak var messagesTableView: UITableView!
    
    // MARK: - Variables
    var friends = [String]()
    var recentMessage = [RecentMessagesModel]()
    let chatDialog = QBChatDialog(dialogID: nil, type: .private)
    var friendName: [String] = []
    var friendImage: [String] = []
    var friendsId = ""
    var friendsQBID : UInt?
    var counter = 0
    
    // MARK: - View's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Functions
    ///setupView...
    func setupView(){
        messagesTableView.register(UINib(nibName: "ChefConversationCell", bundle: nil), forCellReuseIdentifier: "ChefConversationCell")
        getUserData()
    }
}

//MARK: - TableView Delegate and Data Source Methods...
extension ChefConversationsList : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: "ChefConversationCell", for: indexPath) as! ChefConversationCell
        let chatsDta = recentMessage[indexPath.row]
       
        cell.data = chatsDta
        let bgview = UIView()
        bgview.backgroundColor = .white
        cell.selectedBackgroundView = bgview
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.item)
        let id = friends[indexPath.row]
        self.getUserOfID(userID: id) { status, user in
            let inboxVC = ChefInboxVC.initiateFrom(Storybaord: .chef)
            inboxVC.foodieId = user!.id
            self.pushViewController(viewController: inboxVC)
        }
    }
}

//MARK: - Network Layers...
extension ChefConversationsList {
    ///getUserData...
    func getUserData(){
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {  }
            else {
                guard let myData = snapShot!.data(), let myUser = ChefUserModel(dictionary: myData) else {
                    return
                }
                self.friends = myUser.contactList
                print("chef friends list", self.friends)
                if Auth.auth().currentUser != nil {
                    self.getLastMessage { list in
                        list.forEach { uid in
                            let num = NSNumber(value: uid)
                            self.createDialog(friendIds: [num])
                        }
                    }
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                }
            }
        }
    }
    
    ///loadLastMessage...
    func loadLastMessage(dialogueID : String) {
        
        QBRequest.messages(withDialogID: dialogueID,extendedRequest: ["sort_desc" : "date_sent", "limit" : "1"],for: nil,successBlock: { (response, messages, page) -> Void in
            for data in messages {
                
                let lastMessage = data.text
                let date = data.dateSent
                let dateformatter = DateFormatter()
                dateformatter.timeStyle = .short
                dateformatter.dateStyle = .short
                let time = dateformatter.string(from: date!)
                
                self.recentMessage.append(RecentMessagesModel(userName: self.friendName[self.counter], userImage: self.friendImage[self.counter], latestMessage: lastMessage! , dateSent: time, QBID: data.recipientID))
                self.counter = self.counter + 1
                print("message data",self.recentMessage)
                DispatchQueue.main.async {
                    self.messagesTableView.reloadData()
                }
                RappleActivityIndicatorView.stopAnimation()
            }
            
        },errorBlock: { (error) -> Void in
            RappleActivityIndicatorView.stopAnimation()
            print(error)
        })
    }
    
    ///getLastMessage...
    func getLastMessage(completion: @escaping ([UInt]) ->()) {
        RappleActivityIndicatorView.startAnimating()
        var friendIds = [UInt]()
        friends.forEach { uid in
            self.getUserOfID(userID: uid) { success, user in
                if success{
                    self.friendName.append(user?.name ?? "")
                    self.friendImage.append(user?.profilePic ?? "")
                    friendIds.append(user?.QBID ?? 0)
                    self.friendsId = user?.id ?? ""
                    self.friendsQBID = user?.QBID ?? 0
                    if self.friends.count == friendIds.count {
                        completion(friendIds)
                    }
                    RappleActivityIndicatorView.stopAnimation()
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                }
            }
        }
        RappleActivityIndicatorView.stopAnimation()
    }
    ///createDialog...
    func createDialog(friendIds: [NSNumber]){
        
        self.chatDialog.occupantIDs = friendIds
        QBRequest.createDialog(self.chatDialog) { response, createdDialog in
            if response.isSuccess {
                print(createdDialog.id!)
                self.loadLastMessage(dialogueID: createdDialog.id!)
                RappleActivityIndicatorView.stopAnimation()
            } else {
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    ///getUserOfID...
    func getUserOfID(userID:String,handler: @escaping(_ success:Bool,_ foodie:FoodieUserModel?)->()){
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let id = data["id"] as? String ?? "Not Found"
                let QBID = data["QBID"] as? UInt ?? 0
                let name = data["name"] as? String ?? "Not Found"
                let email = data["email"] as? String ?? "Not Found"
                let role = data["role"] as? String ?? "Not Found"
                let instagramLink = data["instagramLink"] as? String ?? "Not Found"
                let tikTokLink = data["tikTokLink"] as? String ?? "Not Found"
                let profilePic = data["profilePic"] as? String ?? "Not Found"
                let address = data["address"] as? String ?? "Not Found"
                let zipCode = data["zipCode"] as? String ?? "Not Found"
                let lat = data["lat"] as? Double ?? 0
                let long = data["long"] as? Double ?? 0
                let fcmToken = data["fcmToken"] as? String ?? "Not Found"
                let contactList = data["contactList"] as? [String] ?? [String]()
                let customerId = data["customerId"] as? String ?? ""
                let pendingClearence = data["pendingClearence"] as? Double ?? 0.0
                let notificationsAllowed = data["notificationsAllowed"] as? Bool ?? true
                
                let foodie = FoodieUserModel(id: id, QBID: QBID, name: name, email: email, role: role, instagramLink: instagramLink, tikTokLink: tikTokLink, profilePic: profilePic,address: address,zipCode: zipCode,fcmToken: fcmToken, lat: lat, long: long, contactList: contactList, customerId: customerId, pendingClearence: pendingClearence, notificationsAllowed: notificationsAllowed)
                
                handler(true,foodie)
            } else {
                RappleActivityIndicatorView.stopAnimation()
                handler(false,nil)
                print("Document does not exist")
            }
        }
    }
    
}
