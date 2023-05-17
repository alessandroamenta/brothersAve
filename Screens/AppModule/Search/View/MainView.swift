//
//  MainView.swift
//  SearchBar
//
//  Created by Ben Meline on 11/16/15.
//  Copyright © 2015 Ben Meline. All rights reserved.
//

import UIKit
import PureLayout

class MainView: UIView {
    
    public var searchBar: UISearchBar!
    public var searchButton: UIButton!
    public var resultsTable: UITableView!
    
    public var searchButtonHeight: CGFloat = 60
    public var searchButtonWidth: CGFloat = 200
    
    private let searchBarStartingAlpha: CGFloat = 0
    private let searchButtonStartingAlpha: CGFloat = 1
    private let tableStartingAlpha: CGFloat = 0
    private let searchBarEndingAlpha: CGFloat = 1
    private let searchButtonEndingAlpha: CGFloat = 0
    private let tableEndingAlpha: CGFloat = 1
    
    private let searchButtonStartingCornerRadius: CGFloat = 20
    private let searchButtonEndingCornerRadius: CGFloat = 0

    private var searchBarTop = false
    private var searchButtonWidthConstraint: NSLayoutConstraint?
    private var searchButtonEdgeConstraint: NSLayoutConstraint?
    private var didSetupConstraints = false
    private var backgroundView: UIImageView!
    private var topView, bottomView: UIView!
    private var topSpace, bottomSpace: UIView!
    public var locationSearchBar: UISearchBar!
    weak var delegate: MainViewDelegate?
   
    let arr = ["Dessert","Plant based dishes","Dinner","Lunch","Breakfast","Cooking Lessons","Recipes"]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        searchBar.delegate  = self
        resultsTable.reloadData()
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    // MARK: - Initialization
    
    func setupViews() {
        setupSearchBar()
        setupSearchButton()
        setupResultsTable()
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar.newAutoLayout()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.alpha = searchBarStartingAlpha
        addSubview(searchBar)
    }
    
    func setupSearchButton() {
        searchButton = UIButton(type: .custom)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchClicked(sender:)), for: .touchUpInside)
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = .blue
        searchButton.layer.cornerRadius = searchButtonStartingCornerRadius
        addSubview(searchButton)
    }
    
    func setupResultsTable() {
        resultsTable = UITableView.newAutoLayout()
        resultsTable.alpha = tableStartingAlpha
        resultsTable.delegate  = self
        resultsTable.dataSource = self
        resultsTable.allowsSelection = true
        resultsTable.register(UINib(nibName: "SearchCategoryCell", bundle: nil), forCellReuseIdentifier: "SearchCategoryCell")
        addSubview(resultsTable)
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        if !didSetupConstraints {
            searchBar.autoAlignAxis(toSuperviewAxis: .vertical)
            searchBar.autoMatch(.width, to: .width, of: self)
            searchBar.autoPinEdge(toSuperviewEdge: .top)
            
            searchButton.autoSetDimension(.height, toSize: searchButtonHeight)
            searchButton.autoAlignAxis(toSuperviewAxis: .vertical)
            
            resultsTable.autoAlignAxis(toSuperviewAxis: .vertical)
            resultsTable.autoPinEdge(toSuperviewEdge: .leading)
            resultsTable.autoPinEdge(toSuperviewEdge: .trailing)
            resultsTable.autoPinEdge(toSuperviewEdge: .bottom)
            resultsTable.autoPinEdge(.top, to: .bottom, of: searchBar)
            
            didSetupConstraints = true
        }
        
        searchButtonWidthConstraint?.autoRemove()
        searchButtonEdgeConstraint?.autoRemove()
        
        if searchBarTop {
            searchButtonWidthConstraint = searchButton.autoMatch(.width, to: .width, of: self)
            searchButtonEdgeConstraint = searchButton.autoPinEdge(toSuperviewEdge: .top)
        } else {
            searchButtonWidthConstraint = searchButton.autoSetDimension(.width, toSize: searchButtonWidth)
           searchButtonEdgeConstraint = searchButton.autoAlignAxis(toSuperviewAxis:  .horizontal)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - User Interaction
    
   @objc func searchClicked(sender: UIButton!) {
       showSearchBar(searchBar: searchBar)
       resultsTable.reloadData()
    }
    
    // MARK: - Helpers
    
    func showSearchBar(searchBar: UISearchBar) {
        searchBarTop = true
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        UIView.animate(withDuration: 0.3,
            animations: {
                searchBar.becomeFirstResponder()
                self.layoutIfNeeded()
            }, completion: { finished in
                UIView.animate(withDuration: 0.2,
                    animations: {
                        searchBar.alpha = self.searchBarEndingAlpha
                        self.resultsTable.alpha = self.tableEndingAlpha
                        self.searchButton.alpha = self.searchButtonEndingAlpha
                        self.searchButton.layer.cornerRadius = self.searchButtonEndingCornerRadius
                    }
                )
            }
        )
    }
    
    func dismissSearchBar(searchBar: UISearchBar) {
        searchBarTop = false
        
        UIView.animate(withDuration: 0.2,
            animations: {
                searchBar.alpha = self.searchBarStartingAlpha
                self.resultsTable.alpha = self.tableStartingAlpha
                self.searchButton.alpha = self.searchButtonStartingAlpha
                self.searchButton.layer.cornerRadius = self.searchButtonStartingCornerRadius
            }, completion:  { finished in
                self.setNeedsUpdateConstraints()
                self.updateConstraintsIfNeeded()
                UIView.animate(withDuration: 0.3,
                    animations: {
                        searchBar.resignFirstResponder()
                        self.layoutIfNeeded()
                    }
                )
            }
        )
    }
    
    @objc func handleDidselectRowAtIndedxPath(sender: UIButton){
        searchBar.text = arr[sender.tag]
        delegate?.searchButtonWasClicked(mainView: self, sender: searchBar)

    }
}

extension MainView: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dismissSearchBar(searchBar: searchBar)
        delegate?.offlineButtonWasClicked(mainView: self, sender: searchBar)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
       
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     delegate?.searchButtonWasClicked(mainView: self, sender: searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchButtonWasClicked(mainView: self, sender: searchBar)
    }
}

protocol MainViewDelegate: NSObject {
    func searchButtonWasClicked(mainView: MainView, sender: UISearchBar!)
    func favoriteButtonWasClicked(mainView: MainView, sender: UIButton!)
    func offlineButtonWasClicked(mainView: MainView, sender: UISearchBar!)
    func infoButtonWasClicked(mainView: MainView, sender: UIButton!)
}

extension MainView: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategoryCell", for: indexPath) as! SearchCategoryCell
        
        cell.lblCategory.text = arr[indexPath.row]
        cell.didSelectBtn.tag = indexPath.row
        cell.didSelectBtn.addTarget(self, action: #selector(handleDidselectRowAtIndedxPath(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
