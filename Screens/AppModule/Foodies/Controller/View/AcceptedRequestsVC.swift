//
//  AcceptedRequestsVC.swift
//  Food App
//
//  Created by HF on 06/01/2023.
//

import UIKit
import CoreLocation
import RappleProgressHUD

class AcceptedRequestsVC: UIViewController {
    
    //MARK: - IBoutlets...
    @IBOutlet weak var acceptedRequestsTableView:UITableView!

    //MARK: - Vars...
    var fieldName = "foodieId"
    let appdelgate = UIApplication.shared.delegate as! AppDelegate
    var buyerRequestArr = [BuyerRequestModel]()
    
    //MARK: - View's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Functions...
    ///setupViews...
    func setupViews(){
        fetchcustomOrder()
    }
    
    ///fetchcustomOrder...
    func fetchcustomOrder(){
        RappleActivityIndicatorView.startAnimating()
        FoodieService.instance.getFoodieAcceptedRequests(fieldName: fieldName) { success, request in
            if success{
                self.buyerRequestArr = request!
                if request?.count == 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    self.acceptedRequestsTableView.reloadData()
                    Alert.showMsg(msg: "No requests found")
                }
                else{
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.acceptedRequestsTableView.reloadData()
                    }
                }
            }
            else{
                RappleActivityIndicatorView.stopAnimation()
                self.acceptedRequestsTableView.reloadData()
                Alert.showMsg(msg: "Something went wrong")
            }
        }
    }
    
    //MARK: - Actions...
    
    @IBAction func backBtnAction(_ sender: UIButton){
        popViewController()
    }
    
    @objc func payNowTapped(_ sender:UIButton){
        let data = buyerRequestArr[sender.tag]
        let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
        appCredentials.isComingfromRequests = true
        appCredentials.isComingfromOrders = false
        appCredentials.isComingfromFood = false
        appCredentials.isComingfromLessons = false
        controller.requestId = data.id
        controller.request = data
        self.pushViewController(viewController: controller)
    }
    
}


extension AcceptedRequestsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyerRequestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptedRequestsCell", for: indexPath) as! AcceptedRequestsCell
        let data = buyerRequestArr[indexPath.row]
        cell.categoryLbl.text = data.category
        cell.descriptionLbl.text = data.description
        if let image = URL(string: data.mediaURl){
            cell.imgView.sd_setImage(with: image, placeholderImage: nil, options: .forceTransition)
        }
        cell.payNowBtn.tag = indexPath.row
        cell.payNowBtn.addTarget(self, action: #selector(payNowTapped), for: .touchUpInside)
        cell.costLbl.text = "$\(data.amount)"
        cell.pickupTimeLbl.text = "\(data.endTime)"
        let bgView = UIView()
        bgView.backgroundColor = .white
        cell.selectedBackgroundView = bgView
        return cell
    }
    
}
