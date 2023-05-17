//
//  TodayPickupVC.swift
//  Food App
//
//  Created by Muneeb Zain on 07/10/2021.
//

import UIKit
import Cosmos
import SDWebImage
import CoreLocation
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore

class TodayPickupVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cosmosView : CosmosView!
    @IBOutlet weak var ratingLbl:UILabel!
    
    //MARK: - Vars...
    var chefId = ""
    var rating : Double = 0.0
    var passFood: ChefCookingModel?
    var chefFoodArr = [ChefCookingModel]()
    var chefUser: ChefUserModel?
    let appdelgate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getChefUser()
        setupViews()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tableView.layer.removeAllAnimations()
        tableViewHeight.constant = tableView.contentSize.height
        UIView.animate(withDuration: 0.5) {
            self.updateViewConstraints()
        }
        
    }
    
    //MARK: - Supporting Functions
    
    ///setupViews...
    func setupViews(){
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.ratingLbl.text = "\(rating) Rating"
            self.updateRating(chefId: self.chefId, rating: rating)
        }
    }
    
    //MARK: - Action
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func btnChatTapped(_ sender: Any){
        let controller: FoodieInboxVC = FoodieInboxVC.initiateFrom(Storybaord: .foodie)
        controller.friend = self.chefUser
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func coursesBtnTapped(_ sender : UIButton){
        RappleActivityIndicatorView.startAnimating()
        let storyboard = UIStoryboard(name: "Chef", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ChefProfileVC") as! ChefProfileVC
        controller.searchedId = self.chefId
        present(controller, animated: true)
    }
    
    ///handlePickButtonTapped....
    @objc func handlePickButtonTapped(sender: UIButton){
        if chefFoodArr[sender.tag].qunatity == "0" {
            RappleActivityIndicatorView.stopAnimation()
            Alert.showMsg(msg: "Could not pick order")
        }
        else{
            RappleActivityIndicatorView.stopAnimation()
            let data = chefFoodArr[sender.tag]
            let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
            appCredentials.isComingfromOrders = false
            appCredentials.isComingfromFood = true
            appCredentials.isComingfromLessons = false
            controller.foodId = data.id
            controller.chefFood = data
            self.pushViewController(viewController: controller)
        }
    }

}


extension TodayPickupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chefFoodArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayPickupCell", for: indexPath) as! TodayPickupCell
        let data = chefFoodArr[indexPath.row]
        cell.titleLbl.text = data.itemName
        let myLocation = CLLocation(latitude: appdelgate.lat ?? 0, longitude: appdelgate.long ?? 0)
        let chefLocation = CLLocation(latitude: data.lat, longitude: data.long)
        let distance = myLocation.distance(from: chefLocation) / 1000
        cell.ingredientLbl.text = "\(data.chefName) | Meals: 350 | \(String(format: "%.01fkm", distance))"
        cell.leftLbl.text = "\(data.qunatity) Left"
        cell.imgView.sd_setImage(with: URL(string: data.images[0]), placeholderImage: nil, options: .forceTransition)
        cell.pickBtn.tag = indexPath.row
        cell.pickBtn.addTarget(self, action: #selector(handlePickButtonTapped(sender:)), for: .touchUpInside)
        let bgView = UIView()
        bgView.backgroundColor = .white
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

//MARK: - Network Layers...
extension TodayPickupVC {
    
    ///getChefUser...
    func getChefUser(){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(passFood!.chefId).getDocument { snapShot, error in
            if error != nil { RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: error?.localizedDescription ?? "") }
            else {
                guard let myData = snapShot!.data(), let Chef = ChefUserModel(dictionary: myData) else {
                    return
                }
                appCredentials.chefId = Chef.id
                self.chefId = Chef.id
                self.chefUser = Chef
                self.lblName.text = Chef.name
                self.profileImgView.sd_setImage(with: URL(string: Chef.profilePic), placeholderImage: UIImage(named: "user"), options: .forceTransition)
                self.ratingLbl.text = "\(Chef.rating) Rating"
                self.getFoods(ids: Chef.cookingIds)
            }
        }
    }
    
    ///getFoods....
    func getFoods(ids: [String]){
        ChefService.instance.getChefTodayCookings(date: "",segmentIndex: 0, CookingsIds: ids) { success, foods in
            if success{
                self.chefFoodArr = foods!
                DispatchQueue.main.async {
                    RappleActivityIndicatorView.stopAnimation()
                    self.tableView.reloadData()
                }
                
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    ///updateRating...
    func updateRating(chefId: String, rating: Double){
        RappleActivityIndicatorView.startAnimating()
        ChefService.instance.updateRating(chefId: self.chefId ?? "", rating: rating) { resultent in
            switch resultent {
            case .success(let success):
                print(success)
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                print(error)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
}

