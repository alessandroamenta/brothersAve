//
//  ViewController.swift
//  Food App
//
//  Created by Chirp Technologies on 27/09/2021.
//

import UIKit
import FirebaseAuth
import RappleProgressHUD
import FirebaseFirestore

class WelcomeVC: UIViewController {
    
    var role = ""
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoLoginMethod()
    }
    
    func autoLoginMethod(){
        if Auth.auth().currentUser != nil {
            if UserDefaults.standard.string(forKey: "userRole") == nil {
                RappleActivityIndicatorView.startAnimating()
                FoodieService.instance.getUserOfFoodieUser(userID: Auth.auth().currentUser?.uid ?? "") { [weak self] success, foodie in
                    if success {
                        if foodie?.role == "Foodie"{
                            FoodieService.instance.FoodieUser = foodie
                            RappleActivityIndicatorView.stopAnimation()
                            FoodieService.instance.setCurrentUser(foodie: foodie!)
                            let controller: tabBarVC = tabBarVC.initiateFrom(Storybaord: .foodie)
                            self?.setNewRootViewController(storyboard: "Foodies", identifier: "tabBarVC")
                            self!.pushViewController(viewController: controller)
                            
                        }
                        else{
                            ChefService.instance.getUserOfChefUser(userID: Auth.auth().currentUser?.uid ?? "") { success, chef in
                                if success{
                                    ChefService.instance.chefUser = chef
                                    RappleActivityIndicatorView.stopAnimation()
                                    ChefService.instance.setCurrentUser(chef: chef!)
                                    let controller: TabbarVC = TabbarVC.initiateFrom(Storybaord: .chef)
                                    self?.setNewRootViewController(storyboard: "Chef", identifier: "TabbarVC")
                                    self!.pushViewController(viewController: controller)
                                }
                                else{
                                    RappleActivityIndicatorView.stopAnimation()
                                    print("Something went wrong")
                                }
                            }
                        }
                    }
                    else{
                        RappleActivityIndicatorView.stopAnimation()
                        print("Something went wrong")
                    }
                }
            }
            else if UserDefaults.standard.string(forKey: "userRole") == "Foodie"{
                RappleActivityIndicatorView.startAnimating()
                FoodieService.instance.getUserOfFoodieUser(userID: Auth.auth().currentUser?.uid ?? "") { [weak self] success, foodie in
                    if success {
                        FoodieService.instance.FoodieUser = foodie
                        RappleActivityIndicatorView.stopAnimation()
                        FoodieService.instance.setCurrentUser(foodie: foodie!)
                        let controller: tabBarVC = tabBarVC.initiateFrom(Storybaord: .foodie)
                        self?.setNewRootViewController(storyboard: "Foodies", identifier: "tabBarVC")
                        self!.pushViewController(viewController: controller)
                    }
                    else{
                        RappleActivityIndicatorView.stopAnimation()
                        print("Something went wrong")
                    }
                }
            }
            else
            {
                RappleActivityIndicatorView.startAnimating()
                ChefService.instance.getUserOfChefUser(userID: Auth.auth().currentUser?.uid ?? "") { [weak self]success, chef in
                    if success{
                        ChefService.instance.chefUser = chef
                        RappleActivityIndicatorView.stopAnimation()
                        ChefService.instance.setCurrentUser(chef: chef!)
                        let controller: TabbarVC = TabbarVC.initiateFrom(Storybaord: .chef)
                        self?.setNewRootViewController(storyboard: "Chef", identifier: "TabbarVC")
                        self!.pushViewController(viewController: controller)
                    }
                    else{
                        RappleActivityIndicatorView.stopAnimation()
                        print("Something went wrong")
                    }
                }
            }
        }
    }
    
    
    //MARK: - Actions
    @IBAction func btnFoodieTapped(_ sender:Any){
        let controller:FoodiesLoginVC = FoodiesLoginVC.initiateFrom(Storybaord: .foodie)
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func btnHomeChefTapped(_ sender: Any){
        let controller:ChefLoginVC = ChefLoginVC.initiateFrom(Storybaord: .chef)
        self.pushViewController(viewController: controller)
    }
    
}

