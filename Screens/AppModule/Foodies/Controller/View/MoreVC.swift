//
//  MoreVC.swift
//  Food App
//
//  Created by Muneeb Zain on 12/10/2021.
//

import UIKit

class MoreVC: UIViewController {

    //MARK: - IBoutlets...
    @IBOutlet weak var bottomSheet:UIView!
    @IBOutlet weak var emailLbl:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    //MARK: - Functions...
    
    func setupViews(){
        
        bottomSheet.layer.masksToBounds = false
        bottomSheet.layer.shadowColor = UIColor.lightGray.cgColor
        bottomSheet.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomSheet.layer.shadowOpacity = 0.3
        bottomSheet.layer.shadowRadius = 3.0
        bottomSheet.roundCorners(corners: [.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 25)
        
        emailLbl.text = appCredentials.email ?? ""
    }
    
    func animation(viewAnimation: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            viewAnimation.frame.origin.y = -self.view.frame.height
        }) { (_) in
        }
    }
    
    func animateBack(viewAnimation : UIView){
        UIView.animate(withDuration: 0.5, animations: {
            viewAnimation.frame.origin.y = self.view.frame.height
        }) { (_) in
            self.bottomSheet.isHidden = true
        }
    }
    

    @IBAction func myProfileBtnPressed(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func paymentMethodsBtnPressed(_ sender: Any) {
        pushViewController(storyboard: "Chef", identifier: "AllCardsVC")
        
    }
    
    @IBAction func termsAndConditionsBtnPressed(_ sender: Any) {
        openLinkWith(urlLink: "https://www.google.com")
    }
    
    @IBAction func needHelpBtnPressed(_ sender: Any) {
        openLinkWith(urlLink: "https://www.google.com")
    }
    
    @IBAction func crossBtnAction(_ sender: UIButton){
        animateBack(viewAnimation: bottomSheet)
    }
    
}
