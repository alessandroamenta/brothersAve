//
//  OrderVC.swift
//  Food App
//
//  Created by Muneeb Zain on 06/10/2021.
//

import UIKit
import CoreLocation
import RappleProgressHUD

class YourOrderVC: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    var fieldName = "foodieId"
    let appdelgate = UIApplication.shared.delegate as! AppDelegate
    var orderArr = [ChefCookingModel]()
    var buyerRequestArr = [BuyerRequestModel]()
    var lessonsArr = [LessonModel]()
    var category = ""
    var type = ""
    var selectIndex = 0
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if fieldName == "foodieId"{
            backBtn.isHidden = true
        }else{
            backBtn.isHidden = false
        }
        fetchOrders()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    //MARK: - Supporting Functions
    
    func fetchOrders(){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.getFoodieOrder(fieldName: fieldName) { success, orders in
            if success{
                self.orderArr = orders!
                if orders?.count == 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    self.tableView.reloadData()
                    Alert.showMsg(msg: "No Order found")
                }
                else{
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.tableView.reloadData()
                    }
                }
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                self.tableView.reloadData()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
        
    ///fetchcustomOrder...
    func fetchCustomOrder(){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.getFoodieCustomRequestOrders(fieldName: fieldName) { success, request in
            if success{
                self.buyerRequestArr = request!
                if request?.count == 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    self.tableView.reloadData()
                    Alert.showMsg(msg: "No Requests found")
                }
                else{
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.tableView.reloadData()
                    }
                }
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                self.tableView.reloadData()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    func fetchOrderedLessons(){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.getFoodieLessonOrders(fieldName: fieldName) { success, request in
            if success {
                self.lessonsArr = request!
                if request?.count == 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    self.tableView.reloadData()
                    Alert.showMsg(msg: "No Lessons found")
                } else {
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.tableView.reloadData()
                    }
                }
            } else {
                RappleActivityIndicatorView.stopAnimation()
                self.tableView.reloadData()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    @objc func handleLocationButtonTapped(sender: UIButton){
        if selectIndex == 0 {
            let data = orderArr[sender.tag]
            if data.category == "Recipe" {
                print("It's a recipe")
            } else {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                    
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:])
                    }}
                else {
                    //Open in browser
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                        
                    }
                }
            }
            
        } else if selectIndex == 1 {
            let data = buyerRequestArr[sender.tag]
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
                }}
            else {
                //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination)
                    
                }
            }
        } else {
            let data = lessonsArr[sender.tag]
            
            if data.type == "Online" {
                print("it's an online lesson")
            } else {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                    
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                        UIApplication.shared.open(url, options: [:])
                    }}
                else {
                    //Open in browser
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(data.lat),\(data.long)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        self.popViewController()
    }
    
    @IBAction func segMentTapped(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            orderArr.removeAll()
            self.selectIndex = 0
            fetchOrders()
        }
        else if sender.selectedSegmentIndex == 1 {
            buyerRequestArr.removeAll()
            self.selectIndex = 1
            fetchCustomOrder()
        } else {
            lessonsArr.removeAll()
            self.selectIndex = 2
            fetchOrderedLessons()
        }
    }
    
}

extension YourOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectIndex == 0 {
            return orderArr.count
        }
        else if selectIndex == 1{
            print(buyerRequestArr.count)
            return buyerRequestArr.count
            
        } else {
            return lessonsArr.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourOrderCell", for: indexPath) as! YourOrderCell
        if selectIndex == 0 {
            let data = orderArr[indexPath.row]
            cell.OrderLbl.text = data.itemName
            if data.category == "Recipe" {
                cell.distanceLbl.isHidden = true
                cell.LocationBtn.isHidden = true
            } else {
                cell.distanceLbl.isHidden = false
                cell.LocationBtn.isHidden = false
                let myLocation = CLLocation(latitude: appdelgate.lat ?? 0, longitude: appdelgate.long ?? 0)
                let chefLocation = CLLocation(latitude: data.lat, longitude: data.long)
                let distance = myLocation.distance(from: chefLocation) / 1000
                cell.distanceLbl.text = "\(String(format: "%.01fkm", distance))"
                if let image = URL(string: data.images[0]){
                    cell.imgView.sd_setImage(with: image, placeholderImage: nil, options: .forceTransition)
                }
                cell.LocationBtn.tag = indexPath.row
                cell.LocationBtn.addTarget(self, action: #selector(handleLocationButtonTapped(sender:)), for: .touchUpInside)
            }
            
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            return cell
        } else if selectIndex == 1{
            let data = buyerRequestArr[indexPath.row]
            cell.OrderLbl.text = data.description
            let myLocation = CLLocation(latitude: appdelgate.lat ?? 0, longitude: appdelgate.long ?? 0)
            let chefLocation = CLLocation(latitude: data.lat, longitude: data.long)
            let distance = myLocation.distance(from: chefLocation) / 1000
            cell.distanceLbl.text = "\(String(format: "%.01fkm", distance))"
            if let image = URL(string: data.mediaURl){
                cell.imgView.sd_setImage(with: image, placeholderImage: nil, options: .forceTransition)
            }
            cell.LocationBtn.tag = indexPath.row
            cell.LocationBtn.addTarget(self, action: #selector(handleLocationButtonTapped(sender:)), for: .touchUpInside)
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            return cell
        } else {
            let data = lessonsArr[indexPath.row]
            cell.OrderLbl.text = data.title
            let type = data.type
            if type == "online" {
                cell.distanceLbl.isHidden = true
                cell.LocationBtn.isHidden = true
            } else {
                cell.distanceLbl.isHidden = false
                cell.LocationBtn.isHidden = false
                print("my coordinates", appdelgate.lat as Any,appdelgate.long as Any)
                print("chef's coordinates", data.lat as Any, data.long as Any)
                let myLocation = CLLocation(latitude: appdelgate.lat!, longitude: appdelgate.long!)
                let chefLocation = CLLocation(latitude: data.lat, longitude: data.long)
                let distance = myLocation.distance(from: chefLocation) / 1000
                cell.distanceLbl.text = "\(String(format: "%.01fkm", distance))"
                cell.LocationBtn.tag = indexPath.row
                cell.LocationBtn.addTarget(self, action: #selector(handleLocationButtonTapped(sender:)), for: .touchUpInside)
            }
            cell.imgView.sd_setImage(with: URL(string: data.image))
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectIndex == 0 {
            let data = orderArr[indexPath.row]
            let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
            appCredentials.isComingfromRequests = false
            appCredentials.isComingfromFood = true
            appCredentials.isComingfromOrders = true
            appCredentials.isComingfromLessons = false
            controller.foodId = data.id
            controller.chefFood = data
            controller.orderId = data.id
            self.pushViewController(viewController: controller)
        } else if selectIndex == 1 {
            let data = buyerRequestArr[indexPath.row]
            let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
            appCredentials.isComingfromFood = false
            appCredentials.isComingfromRequests = true
            appCredentials.isComingfromLessons = false
            appCredentials.isComingfromOrders = true
            controller.requestId = data.id
            controller.request = data
            self.pushViewController(viewController: controller)
        } else {
            let data = lessonsArr[indexPath.row]
            let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
            appCredentials.isComingfromFood = false
            appCredentials.isComingfromRequests = false
            appCredentials.isComingfromLessons = true
            appCredentials.isComingfromOrders = true
            controller.lessonId = data.id
            controller.lesson = data
            controller.orderId = data.id
            self.pushViewController(viewController: controller)
        }
        
    }
        
}

