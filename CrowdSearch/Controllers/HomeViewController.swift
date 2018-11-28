//
//  HomeViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var wrongLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Auth.auth().addStateDidChangeListener ({ (auth, user) in
            if user != nil{
                self.performSegue(withIdentifier: "Login", sender: nil)
            } else{
                // user logout
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        if let email = self.emailTextField.text {
            if let password = self.passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { user, error in
                     if error == nil && user != nil{
                        print("User Loged In!")
                        self.performSegue(withIdentifier: "Login", sender: nil)
                        self.wrongLabel.isHidden = true
                     } else {
                        print("Error login user: \(error!.localizedDescription)")
                        self.wrongLabel.isHidden = false
                    }
                }
            }
        }
    }
}

