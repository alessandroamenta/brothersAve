//
//  FoodCategoriesVC.swift
//  Food App
//
//  Created by Muneeb Zain on 07/10/2021.
//

import UIKit
import Quickblox
import SDWebImage
import FirebaseAuth
import CoreLocation
import RappleProgressHUD
import FirebaseFirestore

class FoodCategoriesVC: UIViewController {
    
    
    //MARK: - Properties
    
    @IBOutlet weak var collectioView2: UICollectionView!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var foodieImgView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    
    //MARK: - Vars...
    private var mainView: MainView!
    private var didSetupConstraints = false
    
    var allRecipes = [ChefCookingModel]()
    var allLessonsArray = [LessonModel]()
    var desserts = 0
    var plantDishes = 0
    var dinners = 0
    var lunchs = 0
    var breakFasts = 0
    
    let foodCatImgArr = [UIImage(named: "Dessert"),UIImage(named: "plantbased"),UIImage(named: "dinner"),UIImage(named: "lunch"),UIImage(named: "breakfast")]
    let foodCatArr = ["Dessert","Plant based dishes","Dinner","Lunch","Breakfast"]
    
    let digitalCatImgArr = [UIImage(named: "food"),UIImage(named: "recipe")]
    let digitalCatArr = ["Cooking Lessons","Recipes"]
    
    var currentFoodie = FoodieService.instance.FoodieUser
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let searchController = UISearchController(searchResultsController:nil)
    var lat = 0.0
    var long = 0.0
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            mainView.autoPin(toTopLayoutGuideOf: self, withInset: 0)
            mainView.autoPin(toBottomLayoutGuideOf: self, withInset: 0)
            mainView.autoPinEdge(toSuperviewEdge: .left)
            mainView.autoPinEdge(toSuperviewEdge: .right)
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    //MARK: - Supporting Funtions
    
    ///setupViews...
    func setupViews(){
        getFoods()
        getAllPostedLessons()
        getAllRecipies()
        getUserData()
        mainView = MainView.newAutoLayout()
        mainView.delegate = self
        searchView.addSubview(mainView)
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectioView2.delegate = self
        collectioView2.dataSource = self
        let tapGester = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        foodieImgView.isUserInteractionEnabled  = true
        foodieImgView.addGestureRecognizer(tapGester)

        if Auth.auth().currentUser != nil {
            let pushManager = PushNotificationManager(userID: Auth.auth().currentUser!.uid)
            pushManager.registerForPushNotifications()
        }
    }
        
    ///imageTapped...
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let controller: ViewAccountVC = ViewAccountVC.initiateFrom(Storybaord: .foodie)
        self.pushViewController(viewController: controller)
    }
    
    
    //MARK: - Actions
    @IBAction func btnChangeLocationTapped(_ sender: Any){
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
    @IBAction func btnSearchFiledTapped(_ sender: Any){
        mainView.searchButton.isHidden  = true
        mainView.searchClicked(sender: mainView.searchButton)
        searchView.isHidden = false
        
    }
    
    @IBAction func btnPostRequestTapped(sender: Any){
        let controller: PostRequestVC = PostRequestVC.initiateFrom(Storybaord: .foodie)
        self.pushViewController(viewController: controller)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}


extension FoodCategoriesVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return foodCatImgArr.count
        }
        else{
            return digitalCatArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCategoriesCollectionCell", for: indexPath) as! FoodCategoriesCollectionCell
            
            switch indexPath.row % 5 {
            case 0:
                let image = UIImage(named: "Dessert")
                cell.imgView.image = image
                cell.foodLbl.text = "Dessert"
                cell.viewLbl.text = "\(desserts) new"
            case 1:
                let image = UIImage(named: "plantbased")
                cell.imgView.image = image
                cell.foodLbl.text = "Plant based dishes"
                cell.viewLbl.text = "\(plantDishes) new"

            case 2:
                let image = UIImage(named: "dinner")
                cell.imgView.image = image
                cell.foodLbl.text = "Dinner"
                cell.viewLbl.text = "\(dinners) new"

            case 3:
                let image = UIImage(named: "lunch")
                cell.imgView.image = image
                cell.foodLbl.text = "Lunch"
                cell.viewLbl.text = "\(lunchs) new"
                
            case 4:
                
                let image = UIImage(named: "breakfast")
                cell.imgView.image = image
                cell.foodLbl.text = "Breakfast"
                cell.viewLbl.text = "\(breakFasts) new"

                
            default:
                print("")
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DigitalCollectioViewCell", for: indexPath) as! DigitalCollectioViewCell
            
            switch indexPath.row % 2 {
            case 0:
                let image = UIImage(named: "food")
                cell.imgView.image = image
                cell.contentLbl.text = "Cooking Lessons"
                cell.newLbl.text = "\(allRecipes.count) new"
            case 1:
                let image = UIImage(named: "recipe")
                cell.imgView.image = image
                cell.contentLbl.text = "Recipes"
                cell.newLbl.text = "\(allLessonsArray.count) new"
                
            default:
                print("")
            }
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView1{
            let dic = ["subCategory":foodCatArr[indexPath.row]]
            appdelegate.category = "food"
            NotificationCenter.default.post(name: Notification.Name("NotificationName"), object: dic)
            tabBarController?.selectedIndex = 1
        }
        else{
            if indexPath.row == 0 {
                let controller: YourLessonsVC = YourLessonsVC.initiateFrom(Storybaord: .chef)
                self.pushViewController(viewController: controller)
            }else{
                let dic = ["subCategory":digitalCatArr[indexPath.row]]
                appdelegate.category = "Recipe"
                NotificationCenter.default.post(name: Notification.Name("NotificationName"), object: dic)
                tabBarController?.selectedIndex = 1
            }
        }
    }
}


extension FoodCategoriesVC: UITextFieldDelegate,DataPass {
    func dataPassing(searchedLocation: String, lat: Double, long: Double) {
        lblAddress.text = searchedLocation
        self.lat = lat
        self.long = long
        print(lat,long)
        var curentFoodie = FoodieService.instance.FoodieUser
        curentFoodie?.lat = lat
        curentFoodie?.long = long
        curentFoodie?.address = searchedLocation
        FoodieService.instance.updateFoodieUser(foodie: currentFoodie!)
    }
}

extension FoodCategoriesVC: MainViewDelegate {
    
    func offlineButtonWasClicked(mainView: MainView, sender: UISearchBar!) {
        searchView.isHidden = true
        
    }
    
    func favoriteButtonWasClicked(mainView: MainView, sender: UIButton!) {
    }
    
    func infoButtonWasClicked(mainView: MainView, sender: UIButton!) {
        
    }
    
    func searchButtonWasClicked(mainView: MainView, sender: UISearchBar!) {
        let storyboard = UIStoryboard(name: "Foodies", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DiscoverVC") as! DiscoverVC
        controller.subSearchString = sender.text!
        let dic = ["subCategory": sender.text]
        NotificationCenter.default.post(name: Notification.Name("NotificationName"), object: dic)
        controller.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - Network Layers...

extension FoodCategoriesVC {
    
    ///getCustomerId...
    func getUserData(){
        RappleActivityIndicatorView.startAnimating()
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { snapShot, error in
            if error != nil {
                Alert.showMsg(msg: "error getting user's data")
                RappleActivityIndicatorView.stopAnimation()
            }
            else {
                guard let myData = snapShot!.data(), let myUser = FoodieUserModel(dictionary: myData) else {
                    return
                }
                self.currentFoodie = myUser
                UserDefaults.standard.set(myUser.lat, forKey: "FoodieLat")
                UserDefaults.standard.set(myUser.long, forKey: "FoodieLong")
                UserDefaults.standard.set(myUser.address, forKey: "FoodieAddress")
                self.foodieImgView.sd_setImage(with: URL(string: myUser.profilePic), placeholderImage: placeHolderImage, options: .forceTransition)
                self.lblAddress.text = myUser.address
                appCredentials.customerStripeId = myUser.customerId
                appCredentials.name = myUser.name
            }
        }
        connectUserWithChatServer()
    }
    
    ///connectUserWithChatServer...
    func connectUserWithChatServer(){
        if appCredentials.isSocialPlatfrom == true {
            let userID = QBSession.current.currentUserID
            let Password = UserDefaults.standard.object(forKey: "foodiePassword") as? String ?? ""
            print("Password",Password)
            QBChat.instance.connect(withUserID: userID, password: Password, completion: { (error) in
                if error != nil {
                    RappleActivityIndicatorView.stopAnimation()
                    print("not connected to chat")
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    print("Connected...")
                }
            })
        } else {
            let userID = QBSession.current.currentUserID
            let Password = Constants.appCredentials.password ?? ""
            QBChat.instance.connect(withUserID: userID, password: Password, completion: { (error) in
                if error != nil {
                    RappleActivityIndicatorView.stopAnimation()
                    print("not connected to chat")
                } else {
                    RappleActivityIndicatorView.stopAnimation()
                    print("Connected...")
                }
            })
        }
    }
    
    ///getFoods...
    func getFoods(){
        RappleActivityIndicatorView.startAnimating()
        
        ChefService.instance.getAllDeserts(subCategory: "Dessert") { resultent in
            switch resultent {
            case .success(let deserts):
                print("All deserts", deserts.count)
                self.desserts = deserts.count
                self.collectionView1.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                print(error)
            }
        }
        
        ChefService.instance.getAllPlantDishes(subCategory: "Plant based dishes") { resultent in
            switch resultent {
            case .success(let deserts):
                print("All plant dishes", deserts.count)
                self.plantDishes = deserts.count
                self.collectionView1.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
        
        ChefService.instance.getAllDinners(subCategory: "Dinner") { resultent in
            switch resultent {
            case .success(let deserts):
                print("All dinners", deserts.count)
                self.dinners = deserts.count
                self.collectionView1.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
        
        ChefService.instance.getAllLunches(subCategory: "Lunch") { resultent in
            switch resultent {
            case .success(let deserts):
                print("All lunchs", deserts.count)
                self.lunchs = deserts.count
                self.collectionView1.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
        
        ChefService.instance.getAllBreakFasts(subCategory: "Breakfast") { resultent in
            switch resultent {
            case .success(let deserts):
                print("All breakfasts", deserts.count)
                self.breakFasts = deserts.count
                self.collectionView1.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
        
    }
    
    ///getAllRecipies...
    func getAllRecipies(){
        RappleActivityIndicatorView.startAnimating()
        ChefService.instance.getAllRecipies { resultent in
            switch resultent {
            case .success(let recipies):
                RappleActivityIndicatorView.stopAnimation()
                self.allRecipes = recipies
                self.collectioView2.reloadData()
                print("All recipies :", self.allRecipes.count)
            case .failure(let error):
                RappleActivityIndicatorView.stopAnimation()
                print(error)
            }
        }
    }
    
    ///getAllPostedLessons...
    func getAllPostedLessons(){
        ChefService.instance.getAllPostedLessons { resultent in
            switch resultent {

            case .success(let response):
                RappleActivityIndicatorView.stopAnimation(); self.allLessonsArray = response;
                print("All lessons :", self.allLessonsArray.count)
                self.collectioView2.reloadData()
            case .failure(let error): RappleActivityIndicatorView.stopAnimation(); print(error)
            }
        }
    }
    
}
