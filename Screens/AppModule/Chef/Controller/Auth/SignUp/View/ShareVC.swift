//
//  ShareVC.swift
//  Food App
//
//  Created by Muneeb Zain on 04/10/2021.
//

import UIKit
import RappleProgressHUD

class ShareVC: UIViewController{
    
    //MARK: - properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblName: UILabel!
    
    var cookingArr = [ChefCookingModel]()
    var currentChef = ChefService.instance.chefUser
    var index = 0
    var segIndex = 0
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblName.text = "Hi \(currentChef?.name ?? "")!"
        getTodayCooking()
        
    }
    
    //MARK: - Supporting Functions
    
    func getTodayCooking(){
        if Utils.isConnectedToNetwork() == true {
            if currentChef?.cookingIds.count ?? 0 > 0 {
                let numbers = currentChef?.cookingIds ?? []
                let result = numbers.chunked(into: 10)
                if index == 0 {
                    RappleActivityIndicatorView.startAnimating()
                    cookingArr.removeAll()
                }
                if index > result.count - 1{
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.index = 0
                        self.collectionView.reloadData()
                    }
                    return
                }
                ChefService.instance.getChefTodayCookings(date: "",segmentIndex: self.segIndex,CookingsIds: result[index], handler: { [weak self] success, cookings in
                    if success{
                        RappleActivityIndicatorView.stopAnimation()
                        DispatchQueue.main.async {
                            
                            self?.cookingArr.append(contentsOf: cookings!)
                            self?.index = (self?.index ?? 0) + 1
                            self?.getTodayCooking()
                        }
                    }
                    else{
                        RappleActivityIndicatorView.stopAnimation()
                        Alert.showMsg(msg: "Something went wrong.")
                    }
                })
            }
            else{
                cookingArr.removeAll()
                self.collectionView.reloadData()
                // Alert.showMsg(msg: "Friends request not found!.")
            }
            
        }
        else{
            Alert.showWithTwoActions(title: "Oops", msg: "Internet not connected please try again", okBtnTitle: "Retry", okBtnAction: {
                self.getTodayCooking()
            }, cancelBtnTitle: "Cancel") {
                
            }
        }
        
    }
    
    
    
    
    //MARK: - Actions
    
    @IBAction func segMentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Active")
            self.segIndex = 0
            getTodayCooking()
            
        }else{
            print("Past")
            self.segIndex = 1
            getTodayCooking()
        }
    }
    
    
}


extension ShareVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cookingArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareCollectionCell", for: indexPath) as! ShareCollectionCell
        let data = cookingArr[indexPath.row]
        cell.imageView.sd_setImage(with: URL(string: data.images[0]), placeholderImage: nil, options: .forceTransition)
        cell.timeLbl.text = data.pickUpDateAndTime
        cell.recipeLbl.text = data.itemName
        cell.lblQunatity.text = data.qunatity
        cell.addressLbl.text = data.pickUpLocation
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width - 10) / 2
        let height = 290
        return CGSize(width: width, height: CGFloat(height))
    }
}
