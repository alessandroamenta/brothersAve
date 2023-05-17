//
//  FoodieMessagesCell.swift
//  Food App
//
//  Created by HF on 06/12/2022.
//

import UIKit

class FoodieMessagesCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var leftUserImage:UIImageView!
    @IBOutlet weak var leftImage:UIImageView!
    @IBOutlet weak var messageLeftLbl:UILabel!
    @IBOutlet weak var dateLeftLbl:UILabel!
    @IBOutlet weak var messageRightLbl:UILabel!
    @IBOutlet weak var dateRightLbl:UILabel!
    @IBOutlet weak var rightUserImage: UIImageView!
    @IBOutlet weak var rightImage:UIImageView!
    @IBOutlet weak var heighConstarint: NSLayoutConstraint!
    @IBOutlet weak var leftHeighConstarint: NSLayoutConstraint!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rightImage.isHidden = true
        self.leftImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
