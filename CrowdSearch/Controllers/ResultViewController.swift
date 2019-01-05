//
//  ResultViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import Firebase

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var link = ""
    var results = [Result]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        results.removeAll()
        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData(){
        let uid = defaults.string(forKey: "uid")
        print(uid)
        DataBaseReference.root.reference().child("result").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            
            if snapshot.key == uid as! String {
                if let dictionary = snapshot.value as? [String: Any] {
                    for i in 0...dictionary.count/3 - 1{
                        let result = Result()
                        result.name = dictionary["name\(i)"] as? String
                        result.url = dictionary["url\(i)"] as? String
                        result.snippet = dictionary["snnipet\(i)"] as? String
                        self.results.append(result)
                    }
                    
                    print(self.results)
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.results.removeAll()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! ResultsCell
        
        cell.titleLabel.text = results[indexPath.row].name
        cell.sourceLabel.text = results[indexPath.row].url
        cell.descriptionLabel.text = results[indexPath.row].snippet
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.link = results[indexPath.row].url!
        self.performSegue(withIdentifier: "Web", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Web" {
            let controller = segue.destination as! WebViewController
            controller.link = self.link
        }
    }
}

