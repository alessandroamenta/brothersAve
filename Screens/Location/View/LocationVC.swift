//
//  LocationViewController.swift
//  MoshPit
//
//  Created by Bukhari Syed Saood on 6/10/20.
//  Copyright © 2020 TerabyteLogixs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol DataPass: NSObject {
    func dataPassing(searchedLocation: String,lat: Double, long: Double)
}

class LocationVC: UIViewController {
    
    @IBOutlet weak var textfieldAddress: UITextField!
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var constraintSearchIconWidth: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapview: MKMapView!
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    weak var delegate: DataPass?
    var isOpenLocationVC = true
    var lat: Double?
    var long: Double?
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfieldAddress.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCurrentLocationTapped(_ sender: Any){
        locationManager.startUpdatingLocation()
        let location = CLLocation(latitude: lat ?? 37.09024, longitude: long ?? -95.712891)
        
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            DispatchQueue.main.async {
                let center  = CLLocationCoordinate2D(latitude: self.lat ?? 37.09024, longitude: self.long ?? -95.712891)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapview.setRegion(region, animated: true)
                self.textfieldAddress.text = "\(placemark.country ?? "") \(placemark.administrativeArea ?? "") \(placemark.subAdministrativeArea ?? "") \(placemark.subLocality ?? "")"
            }
        }
    }
    
    @IBAction func btnSelectAddress(_ sender: Any) {
        if textfieldAddress.text != "" {
            self.delegate?.dataPassing(searchedLocation: self.textfieldAddress.text ?? "United States",lat: lat ?? 37.09024,long: long ?? -95.712891)
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            Alert.showMsg(msg: "Please search and select location or tap on location button to user your current location")
        }
    }
    
    
    
    func showResults(string:String){
        var input = GInput()
        input.keyword = string
        GoogleApi.shared.callApi(input: input) { (response) in
            if response.isValidFor(.autocomplete) {
                DispatchQueue.main.async {
                    self.searchView.isHidden = false
                    self.autocompleteResults = response.data as! [GApiResponse.Autocomplete]
                    self.tableviewSearch.reloadData()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
    func hideResults(){
        searchView.isHidden = true
        autocompleteResults.removeAll()
        tableviewSearch.reloadData()
    }
}

extension LocationVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideResults() ;
        self.navigationController?.popViewController(animated: true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        if fullText.count > 2 {
            showResults(string:fullText)
        }else{
            hideResults()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        constraintSearchIconWidth.constant = 0.0 ; return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        constraintSearchIconWidth.constant = 38.0 ; return true
        
    }
}

extension LocationVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var input = GInput()
        let destination = GLocation.init(latitude: mapview.region.center.latitude, longitude: mapview.region.center.longitude)
        input.destinationCoordinate = destination
        GoogleApi.shared.callApi(.reverseGeo , input: input) { (response) in
            if let places = response.data as? [GApiResponse.ReverseGio], response.isValidFor(.reverseGeo) {
                DispatchQueue.main.async {
                    self.textfieldAddress.text = places.first?.formattedAddress
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}

extension LocationVC : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell")
        let label = cell?.viewWithTag(1) as! UILabel
        label.text = autocompleteResults[indexPath.row].formattedAddress
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textfieldAddress.text = autocompleteResults[indexPath.row].formattedAddress
        textfieldAddress.resignFirstResponder()
        var input = GInput()
        input.keyword = autocompleteResults[indexPath.row].placeId
        GoogleApi.shared.callApi(.placeInformation,input: input) { (response) in
            if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                DispatchQueue.main.async {
                    self.searchView.isHidden = true
                    if let lat = place.latitude, let lng = place.longitude{
                        let center  = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.lat = lat
                        self.long = lng
                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        self.mapview.setRegion(region, animated: true)
                    }
                    self.tableviewSearch.reloadData()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}

extension LocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // set the value of lat and long
        lat = location.latitude
        long = location.longitude
        
    }
}
