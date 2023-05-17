//
//  TodayPickupCell.swift
//  Food App
//
//  Created by Muneeb Zain on 07/10/2021.
//

import UIKit

class TodayPickupCell: UITableViewCell {

    @IBOutlet weak var pickBtn: UIButton!
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var ingredientLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
