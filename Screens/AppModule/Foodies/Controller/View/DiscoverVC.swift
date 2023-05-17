//
//  DiscoverVC.swift
//  Food App
//
//  Created by Muneeb Zain on 06/10/2021.
//

import UIKit
import CoreLocation
import DropDown
import SDWebImage
import FirebaseAuth
import RappleProgressHUD

class DiscoverVC: UIViewController,UISearchBarDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var btnDropDownTitle: UIButton!
    @IBOutlet weak var dropDown: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet weak var btnBack: UIButton!
    
    //MARK: - Vars...
    let appdelgate = UIApplication.shared.delegate as! AppDelegate
    let drop = DropDown()
    let dinnerArray = ["All","Dessert","Plant based dishes","Dinner","Lunch","Breakfast"]
    var foodArr = [ChefCookingModel]()
    var filteredFoodArr = [ChefCookingModel]()
    var searchString = ""
    var subSearchString = ""
    
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if subSearchString == "" {
            getFoods()
        } else {
            self.btnBack.isHidden = false
            getFoodsByCategory(item: subSearchString, categoryFieldName: "subCategory")
        }
        
        searchBar.delegate = self
        drop.anchorView = dropDown
        drop.dataSource = dinnerArray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(handleMassage),name: Notification.Name("NotificationName"),object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Suporrting Functions
    func getFoods(){
        RappleActivityIndicatorView.startAnimating()
        foodArr.removeAll()
        filteredFoodArr.removeAll()
        FoodieService.instance.getfoodieFoodAll() { [self] success, foods in
            if success {
                print("foods count", foods?.count)
                self.foodArr = foods!
                print(self.foodArr)
                self.filteredFoodArr = foods!
//                print(self.filteredFoodArr)
//                DispatchQueue.main.async { [self] in
//                    RappleActivityIndicatorView.stopAnimation()
//                    if searchString != nil {
//                        btnBack.isHidden = false
//                        searchBar.text = searchString
//                        filteredFoodArr = (filteredFoodArr).filter {
//                            return $0.description.range(of: searchString, options: .caseInsensitive) != nil
//                        }
//                        tableView.reloadData()
//                    }
//                    self.tableView.reloadData()
//                }
                
                self.tableView.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    func getAllFoodsOnSearch(){
        //RappleActivityIndicatorView.startAnimating()
        foodArr.removeAll()
        filteredFoodArr.removeAll()
        FoodieService.instance.getfoodieFoodAll() { [self] success, foods in
            if success {
                print("foods count", foods?.count)
                self.foodArr = foods!
                print(self.foodArr)
                self.filteredFoodArr = foods!
                self.tableView.reloadData()
                //RappleActivityIndicatorView.stopAnimation()
            }
            else{
                //RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    func getFoodsByCategory(item: String,categoryFieldName: String){
        RappleActivityIndicatorView.startAnimating()
        foodArr.removeAll()
        filteredFoodArr.removeAll()
        FoodieService.instance.getfoodieFood(subCategory: categoryFieldName, search: item) { success, foods in
            if success{
                self.btnDropDownTitle.setTitle(item, for: .normal)
                self.searchBar.text = item
                self.foodArr = foods!
                print(self.foodArr)
                self.filteredFoodArr = foods!
                print(self.filteredFoodArr)
                DispatchQueue.main.async {
                    RappleActivityIndicatorView.stopAnimation()
                    self.tableView.reloadData()
                }
            }
            else{
                self.btnDropDownTitle.setTitle("All", for: .normal)
                RappleActivityIndicatorView.stopAnimation()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }

    @objc func handleMassage(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let subCategory = dict["subCategory"] as? String {
                if subCategory == "Recipes"{
                    self.btnDropDownTitle.setTitle("All", for: .normal)
                    getFoods()
                }else{
                    self.btnDropDownTitle.setTitle(subCategory, for: .normal)
                    getFoodBySearch(item: subCategory, categoryFieldName: "subCategory")
                }
            }
        }
    }
    
    func getFoodBySearch(item: String,categoryFieldName: String){
        foodArr.removeAll()
        filteredFoodArr.removeAll()
        FoodieService.instance.getfoodieFood(subCategory: categoryFieldName, search: item) { success, foods in
            if success{
                self.btnDropDownTitle.setTitle(item, for: .normal)
                self.searchBar.text = item
                self.foodArr = foods!
                print(self.foodArr)
                self.filteredFoodArr = foods!
                print(self.filteredFoodArr)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else{
                self.btnDropDownTitle.setTitle("All", for: .normal)
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.trimWhiteSpace()
        if searchString != "", searchString.count > 0 {
            filteredFoodArr = (filteredFoodArr).filter {
                return $0.description.range(of: searchString, options: .caseInsensitive) != nil
            }
            getFoodBySearch(item: searchString, categoryFieldName: "subCategory")
        }
        else{
            self.btnDropDownTitle.setTitle("All", for: .normal)
            self.filteredFoodArr = foodArr
            self.tableView.reloadData()
        }
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
    @IBAction func showDinnerBtnPressed(_ sender: Any) {
        
        drop.show()
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.btnDropDownTitle.setTitle(item, for: .normal)
            if item == "All" {
                getFoods()
            }
            else{
                getFoodsByCategory(item: item, categoryFieldName: "subCategory")
            }
        }
    }
    
    @objc func handlePickButtonTapped(sender: UIButton){
        
        if foodArr[sender.tag].qunatity == "0" {
            Alert.showMsg(msg: "Could not pick order")
        }
        else{
            RappleActivityIndicatorView.stopAnimation()
            let data = foodArr[sender.tag]
            let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
            appCredentials.isComingfromOrders = false
            appCredentials.isComingfromRequests = false
            appCredentials.isComingfromFood = true
            appCredentials.isComingfromLessons = false
            controller.foodId = data.id
            controller.chefFood = data
            self.pushViewController(viewController: controller)
        }
    }
}

extension DiscoverVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoodArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! DiscoverCell
        let data = filteredFoodArr[indexPath.row]
        if data.category == "recipe"{
            cell.pickBtn.isHidden = true
            cell.mealLbl.text = "\(data.chefName)"
            cell.leftLbl.text = "Recipe"
        }else{
            let myLocation = CLLocation(latitude: appdelgate.lat ?? 0, longitude: appdelgate.long ?? 0)
            let chefLocation = CLLocation(latitude: data.lat, longitude: data.long)
            let distance = myLocation.distance(from: chefLocation) / 1000
            cell.pickBtn.isHidden = false
            cell.mealLbl.text = "\(data.chefName) | Meals: 350 | \(String(format: "%.01fkm", distance))"
            cell.leftLbl.text = "\(data.qunatity) Left"
            cell.pickBtn.tag = indexPath.row
            cell.pickBtn.addTarget(self, action: #selector(handlePickButtonTapped(sender:)), for: .touchUpInside)
        }
        cell.orderLbl.text = data.itemName
        if let image = URL(string: data.images[0]) {
            cell.imgView.sd_setImage(with: image, placeholderImage: nil, options: .forceTransition)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller: TodayPickupVC = TodayPickupVC.initiateFrom(Storybaord: .foodie)
        let data = filteredFoodArr[indexPath.row]
        controller.passFood = data
        self.pushViewController(viewController: controller)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 110
        
    }
}



