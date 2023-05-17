//
//  ViewAccountVC.swift
//  Food App
//
//  Created by Muneeb Zain on 12/10/2021.
//

import UIKit
import Imaginary
import RappleProgressHUD

class ViewAccountVC: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var foodieImgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var emailName: UILabel!
    
    //MARK: - Vars...
    let currentFoodie = FoodieService.instance.FoodieUser

    
    //MARK:  - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setFoodieProfile()
    }
    
    
    //MARK: - Supporting Functions
    
    ///setFoodieProfile...
    func setFoodieProfile(){
        let tapGester = UITapGestureRecognizer(target: self, action: #selector(handleTappedOnImage))
        
        foodieImgView.addGestureRecognizer(tapGester)
        lblName.text = currentFoodie?.name ?? ""
        emailName.text = currentFoodie?.email ?? ""
        foodieImgView.sd_setImage(with: URL(string: currentFoodie?.profilePic ?? ""), placeholderImage: UIImage(systemName: "person.circle.fill"), options: .forceTransition)

    }
    
    ///handleTappedOnImage...
    @objc func handleTappedOnImage(sender: UITapGestureRecognizer){
        ImagePickerManager().pickImage(self) { videoURl in
            
        } _: { image in
            self.foodieImgView.image = image
            RappleActivityIndicatorView.startAnimating()
            DataService.instance.uploadPIcture(image: image) { success, Url in
                if success{
                    var updateFoodie = self.currentFoodie
                    updateFoodie?.profilePic = Url
                    FoodieService.instance.updateFoodieUser(foodie: updateFoodie!)
                    FoodieService.instance.setCurrentUser(foodie: updateFoodie!)
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "Picture update successfully")
                }
                else{
                    RappleActivityIndicatorView.stopAnimation()
                }
            }
        }
    }
    
    @IBAction func editBtnTapped(_ sender:UIButton){
        ImagePickerManager().pickImage(self) { videoURl in
            
        } _: { image in
            self.foodieImgView.image = image
            RappleActivityIndicatorView.startAnimating()
            DataService.instance.uploadPIcture(image: image) { success, Url in
                if success{
                    var updateFoodie = self.currentFoodie
                    updateFoodie?.profilePic = Url
                    FoodieService.instance.updateFoodieUser(foodie: updateFoodie!)
                    FoodieService.instance.setCurrentUser(foodie: updateFoodie!)
                    RappleActivityIndicatorView.stopAnimation()
                    Alert.showMsg(msg: "Picture update successfully")
                }
                else{
                    RappleActivityIndicatorView.stopAnimation()
                }
            }
        }
    }
    //MARK: - Actions
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.popViewController()
    }
    

}
