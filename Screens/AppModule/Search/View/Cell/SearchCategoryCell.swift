//
//  SearchCategoryCell.swift
//  Food App
//
//  Created by Chirp Technologies on 23/11/2021.
//

import UIKit

class SearchCategoryCell: UITableViewCell {

    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var didSelectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
