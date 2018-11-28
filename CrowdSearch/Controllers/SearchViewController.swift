//
//  SearchViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth


class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet weak var searchMap: MKMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var countries = [String]()
    let regionRadius: CLLocationDistance = 1000000000000000000
    var countriesCounter = 0
    var search: String!
    var mapSize: CGRect!
    var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    var locationString: String = ""
    var users = [User]()
    var selectedCountry: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapSize = self.searchMap.frame
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapGesture)
        
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        self.locationPicker.isHidden = true
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        self.locationPicker.reloadAllComponents()
    }
    
    func fetchData(){
        DataBaseReference.root.reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                var count = 0
                let user = User()
                user.uid = dictionary["uid"] as? String
                user.lat = dictionary["lat"] as? Double
                user.lon = dictionary["lon"] as? Double
                user.location = dictionary["location"] as? String
                user.email = dictionary["email"] as? String
                
                self.users.append(user)
                if self.countries.count > 0{
                    for i in self.countries{
                        if i == dictionary["location"] as! String && i != self.locationString{
                            count+=1
                        }
                    }
                    if count > 0 && dictionary["location"] as! String != self.locationString{
                        self.countries.append(dictionary["location"] as! String)
                    }
                }
                else if dictionary["location"] as! String != self.locationString{
                    self.countries.append(dictionary["location"] as! String)
                }
                self.locationPicker.reloadAllComponents()
            }
            
        }, withCancel: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        self.searchTextField.resignFirstResponder()
    }
    
    
    @IBAction func searchPressed(_ sender: Any) {
        if let search = searchTextField.text {
            if  searchTextField.text != ""{
                self.search = search
                self.searchTextField.resignFirstResponder()
                self.searchTextField.isHidden = true
                self.locationPicker.isHidden = false
                self.mainButton.isHidden = true
                self.searchMap.isHidden = false
                self.searchButton.isHidden = false
                self.addLocationButton.isHidden = false
                self.searchButton.alpha = 0.5
                self.addLocationButton.isEnabled = true
                self.addLocationButton.alpha = 1
                self.searchButton.isEnabled = false
                self.guideLabel.text = "Where do you want to search about " + search + "?"
                
            }
        }
    }
    
    func handleSearch (){
        let ref = DataBaseReference.root.reference().child("requests")
        let childRef = ref.childByAutoId()
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM/yyy"
        let dateString = formatter.string(from: now)
        
        var enabledUsers = [User]()
        
        for i in 0...users.count-1{
            if users[i].location == selectedCountry{
                enabledUsers.append(users[i])
            }
        }
        
        for i in enabledUsers{
            let values = ["search": searchTextField.text!, "fromId": Auth.auth().currentUser?.uid, "toId": i.uid, "location": i.location, "result": "", "data": dateString]
            childRef.updateChildValues(values)
        }
    }
    
    @IBAction func clickSearch(_ sender: Any) {
        handleSearch()
        self.performSegue(withIdentifier: "Search", sender: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    @IBAction func addLocationClick(_ sender: Any) {
        self.searchButton.alpha = 1
        self.searchButton.isEnabled = true
        
        if countriesCounter < 1{
            let annotation = MKPointAnnotation()
            
            var number = locationPicker.selectedRow(inComponent: 0)
            self.selectedCountry = self.countries[number]
            
            var lat = 0.0
            var lon = 0.0
            for i in users{
                if i.location == self.selectedCountry{
                    lat = i.lat!
                    lon = i.lon!
                }
            }
            var mapPoint = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.coordinate = mapPoint
            searchMap.addAnnotation(annotation)
            searchMap.setCenter(mapPoint, animated: true)
            countriesCounter += 1
            if countriesCounter >= 1{
                self.addLocationButton.isHidden = true
                self.locationPicker.isHidden = true
                
                self.searchMap.frame = CGRect(x: 0, y: self.searchMap.layer.position.y/2.05, width: self.searchMap.frame.width, height: self.searchMap.frame.height*1.82)
                self.guideLabel.text = "Tap to search about " + search + " at the pinned location..."
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchTextField.resignFirstResponder()
        self.searchTextField.text = ""
        self.searchTextField.isHidden = false
        self.addLocationButton.isHidden = true
        self.locationPicker.isHidden = true
        self.searchMap.isHidden = true
        self.mainButton.isHidden = false
        self.guideLabel.text = "What do you want to search?"
        let allAnnotations = self.searchMap.annotations
        self.searchMap.removeAnnotations(allAnnotations)
        self.searchButton.alpha = 0.5
        self.addLocationButton.isEnabled = false
        self.addLocationButton.alpha = 0.5
        self.searchButton.isEnabled = false
        self.searchButton.isHidden = true
        self.searchMap.frame = self.mapSize
        self.countriesCounter = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.countries.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let latAsString = String(locValue.latitude)
        let lat = Double(latAsString)
        let lngAsString = String(locValue.longitude)
        let lng = Double(lngAsString)
        let location = CLLocation(latitude: Double(lat!), longitude: Double(lng!))
        
        if let uid = Auth.auth().currentUser?.uid{
            let ref = DataBaseReference.root.reference().child("users/\(uid)")
            ref.updateChildValues(["lat" : Double(lat!)])
            ref.updateChildValues(["lon" : Double(lng!)])
        }
        
        
        // Geocode Location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                
                self.locationString = placemark.country!
                if let uid = Auth.auth().currentUser?.uid {
                    let ref = DataBaseReference.root.reference().child("users/\(uid)")
                    ref.updateChildValues(["location" : placemark.country!])
                }
            } else {
                print("No Matching Addresses Found")
            }
        }
    }
}
