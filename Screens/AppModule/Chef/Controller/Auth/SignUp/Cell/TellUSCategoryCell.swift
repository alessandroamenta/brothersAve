//
//  OnBoard4Cell.swift
//  Motivia App
//
//  Created by Hamza Shahbaz on 01/04/2021.
//

import UIKit

class TellUSCategoryCell: UICollectionViewCell {

    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var lbltitleText: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
    }
}
