//
//  AllBuyerRequestVC.swift
//  Food App
//
//  Created by Chirp Technologies on 24/03/2022.
//

import UIKit
import FirebaseAuth
import CoreLocation
import RappleProgressHUD
import FirebaseFirestore

class AllBuyerRequestVC: UIViewController {

    //MARK: - @IBoutles
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    var currentChef = ChefService.instance.chefUser
    var buyerRequestArr = [BuyerRequestModel]()
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
                self.locationManager.startMonitoringSignificantLocationChanges()
                self.locationManager.distanceFilter = 10
            }
        }
    }

    //MARK: - Supporting Functions
    @objc func handleAcceptTapped(sender: UIButton){
        let request = buyerRequestArr[sender.tag]
        request.accept = true
        self.createAcceptedBuyerRequests(request: request, chefId: Auth.auth().currentUser!.uid, foodieId: request.foodieID)
    }
    
    ///acceptBuyerRequest...
    func createAcceptedBuyerRequests(request: BuyerRequestModel, chefId: String, foodieId: String){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.createAcceptedBuyerRequests(request: request, chefID: chefId) { resultent in
            switch resultent {
            case .success(let success):
                self.getFcmAndSendNotifications(foodieId: foodieId, amount: request.amount)
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: success)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: error)
            }
        }
    }
    
    ///getFcmAndSendNotifications...
    func getFcmAndSendNotifications(foodieId: String, amount: Double){
        Firestore.firestore().collection("users").document(foodieId).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                let data = snapshot?.data(); let foodieData = FoodieUserModel(dictionary: data!)
                let fcm = foodieData?.fcmToken ?? ""
                print("Foodie FCM:", fcm)
                self.sendSingleNotification(title: "Food App", message: "\(appCredentials.name ?? "Someone") has Accepted your Request, check in Accepted Requests Section and pay '$\(amount)' now", receiverToken: fcm)
            }
        }
    }
    
    ///deleteOrder...
    func removeRequestAfterAccepting(orderId: String){
        FoodieService.instance.deleteRequest(orderId: orderId) { resultent in
            switch resultent {
            case .success(let response):
                RappleActivityIndicatorView.stopAnimation()
                print(response)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
               print(error)
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
}

extension AllBuyerRequestVC {
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

extension AllBuyerRequestVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        RappleActivityIndicatorView.startAnimating()
        ChefService.instance.getBuyerRequest { success, request in
            if success {
                
                self.buyerRequestArr = request!
                print("resquests count", self.buyerRequestArr)
                self.tableView.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "unable to get Or no buyer request found")
                print("unable to get no request found")
            }
        }
    
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
}

extension AllBuyerRequestVC: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyerRequestArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
        let data = buyerRequestArr[indexPath.row]
        cell.lblTitle.text = data.category
        cell.lblDays.text = data.description
        cell.lblAmount.text = "$\(data.amount)"
        cell.btnAccept.tag = indexPath.row
        cell.imgView.sd_setImage(with: URL(string: data.mediaURl), placeholderImage: UIImage(named: "food"), options: .forceTransition)
        cell.btnAccept.addTarget(self, action: #selector(handleAcceptTapped(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//**************************************************************\\

//MARK: - Request Cell Class
class RequestCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle:  UILabel!
    @IBOutlet weak var lblDays:  UILabel!
    @IBOutlet weak var lblAmount:  UILabel!
    @IBOutlet weak var btnAccept:  UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
