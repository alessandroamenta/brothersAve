//
//  LessonCell.swift
//  Food App
//
//  Created by Hamza Shahbaz on 01/03/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LessonCell: UITableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var lblChefName: UILabel!
    @IBOutlet weak var lblLessonDate: UILabel!
    @IBOutlet weak var lblLessonTitle: UILabel!
    @IBOutlet weak var lessonImgView: UIImageView!
    @IBOutlet weak var lblLessonDesc: UILabel!
    
    @IBOutlet weak var btnEditTapped: UIButton!
    @IBOutlet weak var btnDeleteTapped: UIButton!
    @IBOutlet weak var btnGetTapped: UIButton!


    //MARK: - DidSet vars...
    var data: LessonModel? {
        didSet {
            guard let data = data else { return }
            let timesAgo = getTimeAgo(postedDate: data.createdAt.dateValue())
            lblLessonDate.text = timesAgo
            lblLessonTitle.text = data.title
            lessonImgView.sd_setImage(with: URL(string: data.image))
            lblLessonDesc.text = data.description
            ChefService.instance.getUserOfChefUser(userID: data.chefId) { success, chef in
                if success{
                    self.lblChefName.text = chef?.name
                    self.userImage.sd_setImage(with: URL(string: chef?.profilePic ?? ""))
                }
            }
            
            if data.chefId == Auth.auth().currentUser?.uid {
                btnEditTapped.isHidden = false
                btnDeleteTapped.isHidden = false
               
            } else {
                btnDeleteTapped.isHidden = false
                btnEditTapped.isHidden = true
                
            }
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
    
    var delegate : YourLessonsVC?
    
    @IBAction func editBtnAction(_ sender : UIButton){
        delegate?.editLessonTap(data: data!)
    }
    
    @IBAction func deleteBtnAction(_ sender : UIButton){
        
        let action = UIAlertAction(title: "Delete", style: .default) { action in  //logout user now...
            guard let data = self.data else { return }; self.delegate?.deletePostedLesson(lessonId: data.id)
        }
        delegate?.presentAlertAndGotoThatFunctionWithCancelBtn(withTitle: "Alert", message: "Are you sure to delete this lesson", OKAction: action, secondBtnTitle: "No")
    }
    
    @IBAction func getLessonBtnAction(_ sender: UIButton){
        
        guard let data = self.data else {return}
        self.delegate?.getLessonTap(data: data)
    }
    
}
