//
//  TellUSVC.swift
//  Food App
//
//  Created by Chirp Technologies on 27/09/2021.
//

import UIKit

class TellUSVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cusineCollectionView: UICollectionView!
    @IBOutlet weak var expertiesCollectionView: UICollectionView!
    @IBOutlet weak var journeyTextView: UITextView!
    
    // MARK: - Variables
    var backgroundArrSelect = [String]()
    var cuisneArrSelect = [String]()
    var ExpertiesArrSelect = [String]()
    var chefModel : ChefUserModel?
    let kItemPadding = 15
    
    
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Functions
    func setupViews(){
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.delegate = self
        expertiesCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        cusineCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
        
    //MARK: - Actions
    @IBAction func backBtnAction(_ sender: UIButton){
        popViewController()
    }
    @IBAction func btnSkipTapped(_ sender: Any){
        let controller: ReadyToGoVC = ReadyToGoVC.initiateFrom(Storybaord: .chef)
        controller.chefModel = self.chefModel
        self.pushViewController(viewController: controller)
    }
    
    @IBAction func btnNextTapped(_ sender: Any){
        let controller: ReadyToGoVC = ReadyToGoVC.initiateFrom(Storybaord: .chef)
        self.chefModel?.journey = journeyTextView.text ?? ""
        controller.chefModel = self.chefModel
        self.pushViewController(viewController: controller)
    }
}

extension TellUSVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cusineCollectionView {
            return cusineArr.count
        }
        else if collectionView == expertiesCollectionView {
            return expertiesArr.count
        }
        else{
            return backgroundArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TellUSCategoryCell", for: indexPath) as! TellUSCategoryCell
        if collectionView == cusineCollectionView {
            cell.lbltitleText.text = cusineArr[indexPath.row]
            return cell
        }
        else if collectionView == expertiesCollectionView {
            cell.lbltitleText.text = expertiesArr[indexPath.row]
            return cell
        }
        else {
            cell.lbltitleText.text = backgroundArr[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cusineCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? TellUSCategoryCell {
                if cell.targetView.layer.borderWidth == 1 {
                    cell.targetView.layer.borderWidth = 0
                    cell.targetView.backgroundColor = .systemYellow
                    self.cuisneArrSelect.append(cusineArr[indexPath.row])
                    self.chefModel?.cusine = self.cuisneArrSelect
                    print(cuisneArrSelect)
                }
                else
                {
                    cell.targetView.layer.borderWidth = 1
                    cell.targetView.backgroundColor  = .lightGray
                    
                    cuisneArrSelect = cuisneArrSelect.filter{$0 != cusineArr[indexPath.row]}
                    print(cuisneArrSelect)
                }
            }
        }
        else if collectionView == expertiesCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? TellUSCategoryCell {
                if cell.targetView.layer.borderWidth == 1 {
                    cell.targetView.layer.borderColor = UIColor.white.cgColor
                    cell.targetView.layer.borderWidth = 0
                    cell.targetView.backgroundColor = .systemYellow
                    self.ExpertiesArrSelect.append(expertiesArr[indexPath.row])
                    self.chefModel?.experties = self.ExpertiesArrSelect
                    print(ExpertiesArrSelect)
                }
                else
                {
                    cell.targetView.layer.borderWidth = 1
                    cell.targetView.backgroundColor = .lightGray
                    ExpertiesArrSelect = ExpertiesArrSelect.filter{$0 != expertiesArr[indexPath.row]}
                    print(ExpertiesArrSelect)
                }
            }
        }
        else
        {
            if let cell = collectionView.cellForItem(at: indexPath) as? TellUSCategoryCell {
                if cell.targetView.layer.borderWidth == 1 {
                    cell.targetView.layer.borderColor = UIColor.white.cgColor
                    cell.targetView.layer.borderWidth = 0
                    cell.targetView.backgroundColor = .systemYellow
                    self.backgroundArrSelect.append(backgroundArr[indexPath.row])
                    self.chefModel?.background = self.backgroundArrSelect
                    print(target)
                    print(backgroundArrSelect)
                }
                else
                {
                    cell.targetView.layer.borderWidth = 1
                    cell.targetView.backgroundColor = .lightGray
                    backgroundArrSelect = backgroundArrSelect.filter{$0 != backgroundArr[indexPath.row]}
                    print(backgroundArrSelect)
                }
            }
        }
    }
}

extension TellUSVC: MICollectionViewBubbleLayoutDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView:UICollectionView, itemSizeAt indexPath:NSIndexPath) -> CGSize{
        if collectionView == cusineCollectionView {
            let title = cusineArr[indexPath.row] as String
            var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Futura Medium", size: 13)!])
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = 40
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            return size
        }
        else if collectionView == expertiesCollectionView {
            let title = expertiesArr[indexPath.row] as String
            var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Futura Medium", size: 13)!])
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = 40
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            return size
        }
        else
        {
            let title = backgroundArr[indexPath.row] as String
            var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Futura Medium", size: 13)!])
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = 40
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            return size
        }
    }
}



