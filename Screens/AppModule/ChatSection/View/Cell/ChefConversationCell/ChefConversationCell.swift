//
//  ChefConversationCell.swift
//  Food App
//
//  Created by HF on 12/12/2022.
//

import UIKit

class ChefConversationCell: UITableViewCell {

    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userNameLbl:UILabel!
    
    @IBOutlet weak var messageLbl:UILabel!
    @IBOutlet weak var timeLbl:UILabel!
    
    // MARK: - Variables
    
    var data : RecentMessagesModel? {
        didSet {
            guard let data = data else {return}
            self.userNameLbl.text = data.userName
            self.messageLbl.text = data.latestMessage
            self.timeLbl.text = data.dateSent
            self.userImage.sd_setImage(with: URL(string: data.userImage))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
