//
//  PaymentsCell.swift
//  Food App
//
//  Created by HF on 06/01/2023.
//

import UIKit

class PaymentsCell: UITableViewCell {

    //MARK: - IBoutlets...
    @IBOutlet weak var amountLbl:UILabel!
    @IBOutlet weak var itemImage:UIImageView!
    @IBOutlet weak var itemNameLbl:UILabel!
    @IBOutlet weak var categoryLbl:UILabel!
    @IBOutlet weak var locationLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!
    @IBOutlet weak var withdrawBtn:UIButton!
    @IBOutlet weak var pendingBtn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Actions...
    @IBAction func withdrawBtnAction(_ sender: UIButton){
        
    }
    
    @IBAction func pendingBtnAction(_ sender: UIButton){
        
    }
    
}
