//
//  YourLessonsVC.swift
//  
//
//  Created by Chirp Technologies on 01/03/2022.
//

import UIKit
import FirebaseAuth
import RappleProgressHUD

class YourLessonsVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var lessonsArr = [LessonModel]()
    
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureCell(tableView: tableView, collectionView: nil, nibName: "LessonCell", reuseIdentifier: "LessonCell", cellType: .tblView)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        getAllPostedLessons()
    }
    
    //MARK: - Supporting Functions
    
    
    //MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any){
        self.popViewController()
    }
    
}

extension YourLessonsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as! LessonCell
        let data = lessonsArr[indexPath.row]
        cell.data = data
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 400
        
    }
}

// MARK: - Network layers...
extension YourLessonsVC {
    
    ///getAllPostedJobs...
    func getAllPostedLessons(){
        ChefService.instance.getAllPostedLessons { resultent in
            switch resultent {

            case .success(let response):
                RappleActivityIndicatorView.stopAnimation(); self.lessonsArr = response;
                self.lessonsArr = self.lessonsArr.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending })
                self.tableView.reloadData()
                if self.lessonsArr.count >= 1 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.lessonsArr.count  - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                }
            case .failure(let error): RappleActivityIndicatorView.stopAnimation(); self.presentAlert(withTitle: "Alert", message: error)
            }
        }
    }
    
    ///deleteJobPost...
    func deletePostedLesson(lessonId: String){
        RappleActivityIndicatorView.startAnimating()
        ChefService.instance.deletePostedLesson(lessonId: lessonId) { resultent in
            switch resultent {
            case .success(_): RappleActivityIndicatorView.stopAnimation()
            case .failure(_): RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
        
    func editLessonTap(data: LessonModel){
        let storyboard = UIStoryboard(name: "Chef", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddLessonsVC1") as! AddLessonsVC1
        controller.isCommingForEdit = true; controller.editData = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getLessonTap(data: LessonModel){
        let controller: FoodDetailsVC = FoodDetailsVC.initiateFrom(Storybaord: .foodie)
        appCredentials.isComingfromRequests = false
        appCredentials.isComingfromFood = false
        appCredentials.isComingfromLessons = true
        appCredentials.isComingfromOrders = false
        controller.lessonId = data.id
        controller.lesson = data
        self.pushViewController(viewController: controller)
    }

}
