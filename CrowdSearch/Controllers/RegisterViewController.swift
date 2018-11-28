//
//  RegisterViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseAuth
import CoreLocation
import MapKit

class RegisterViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    var locationString: String = ""
    var userLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapGesture)
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let userLocation = locations.last
        self.userLocation = userLocation!
        let latAsString = String(locValue.latitude)
        let lat = Double(latAsString)
        let lngAsString = String(locValue.longitude)
        let lng = Double(lngAsString)
        
        let location = CLLocation(latitude: Double(lat!), longitude: Double(lng!))
        
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
                locationLabel.text = "Your Location: \(self.locationString)"
            } else {
                print("No Matching Addresses Found")
            }
        }
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        if let email = self.emailTextField.text{
            if let password = self.passwordTextField.text{
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error == nil && user != nil{
                        var newUser = User()
                        
                        newUser.uid = (user?.user.uid)!
                        newUser.email = self.emailTextField.text!
                        newUser.location = self.locationString
                        newUser.lat = self.userLocation.coordinate.latitude
                        newUser.lon = self.userLocation.coordinate.longitude
                        
                        print("User created!")
                        newUser.save()
                    
                    } else {
                        print("Error creating user: \(error!.localizedDescription)")
                    }
                    self.performSegue(withIdentifier: "Register", sender: nil)
                }
            }
        }
    }
}
