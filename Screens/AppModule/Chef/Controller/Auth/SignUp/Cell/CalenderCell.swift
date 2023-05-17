//
//  CalenderCell.swift
//  Food App
//
//  Created by Muneeb Zain on 18/02/2022.
//

import UIKit

class CalenderCell: UITableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var lblSchedule: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
