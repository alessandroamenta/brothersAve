//
//  CalenderVC.swift
//  Food App
//
//  Created by Muneeb Zain on 12/10/2021.
//

import UIKit
import RappleProgressHUD
import FSCalendar

class CalenderVC: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectDate: UILabel!
    
    var currentChef = ChefService.instance.chefUser
    var cookingArr = [ChefCookingModel]()
    var index = 0
    var selectedDate: String?
    //MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.delegate = self
        calender.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "MMMM dd, yyyy"
        let result = formatter.string(from: Date())
        let result1 = dateformatter1.string(from: Date())
        lblSelectDate.text = result1
        self.selectedDate = result
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        getTodayCooking(date: self.selectedDate ?? "")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tableView.layer.removeAllAnimations()
        tableViewHeight.constant = tableView.contentSize.height
        UIView.animate(withDuration: 0.5) {
            self.updateViewConstraints()
        }

    }
    
    //MARK: - Supporting Functions
    
    func getTodayCooking(date: String){
        if Utils.isConnectedToNetwork() == true {
            if currentChef?.cookingIds.count ?? 0 > 0 {
                let numbers = currentChef?.cookingIds ?? []
                let result = numbers.chunked(into: 10)
                if index == 0 {
                    RappleActivityIndicatorView.startAnimating()
                    cookingArr.removeAll()
                }
                if index > result.count - 1{
                    DispatchQueue.main.async {
                        RappleActivityIndicatorView.stopAnimation()
                        self.index = 0
                        self.tableView.reloadData()
                    }
                    return
                }
                ChefService.instance.getChefTodayCookings(date: date,segmentIndex: 0,CookingsIds: result[index], handler: { [weak self] success, cookings in
                    if success{
                        RappleActivityIndicatorView.stopAnimation()
                        DispatchQueue.main.async {
                            
                            self?.cookingArr.append(contentsOf: cookings!)
                            self?.index = (self?.index ?? 0) + 1
                            self?.getTodayCooking(date: self?.selectedDate ?? "")
                        }
                    }
                    else{
                        RappleActivityIndicatorView.stopAnimation()
                        Alert.showMsg(msg: "Something went wrong.")
                    }
                })
            }
            else{
                cookingArr.removeAll()
               // self.collectionView.reloadData()
                // Alert.showMsg(msg: "Friends request not found!.")
            }
            
        }
        else{
            Alert.showWithTwoActions(title: "Oops", msg: "Internet not connected please try again", okBtnTitle: "Retry", okBtnAction: {
                self.getTodayCooking(date: self.selectedDate ?? "")
            }, cancelBtnTitle: "Cancel") {
                
            }
        }
        
    }

    
    //MARK: - Actions
    
    
}

//MARK: - FSCalender Delegate dataSource

extension CalenderVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "MMMM dd, yyyy"
        let result = formatter.string(from: date)
        let result1 = dateformatter1.string(from: date)
        lblSelectDate.text = result1
        self.selectedDate = result
        getTodayCooking(date: result)
        
    }
    
}

//MARK: - TableViewDelegate/DataSource
extension CalenderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookingArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
        let data = cookingArr[indexPath.row]
        cell.lblSchedule.text  = "\(data.itemName)  \(data.pickUpDateAndTime)"
        return cell
    }
    
    
    
}
