//
//  HistoryViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [Requests]()
    var pastResults = [Requests]()
    var waitingResults = [Requests]()
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        self.tableView.reloadData()
    }
    
    func fetchData(){
        self.pastResults.removeAll()
        self.waitingResults.removeAll()
        self.requests.removeAll()
        self.tableView.reloadData()
        DataBaseReference.root.reference().child("requests").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let request = Requests()
                request.toId = dictionary["toId"] as? String
                request.fromId = dictionary["fromId"] as? String
                request.search = dictionary["search"] as? String
                request.location = dictionary["location"] as? String
                request.result = dictionary["result"] as? String
                request.data = dictionary["data"] as? String
                request.uid = snapshot.key
                self.requests.append(request)
                
                if request.fromId == Auth.auth().currentUser?.uid{
                    if request.result == ""{
                        self.waitingResults.append(request)
                    }
                    else{
                        self.pastResults.append(request)
                    }
                }
                self.tableView.reloadData()
                if self.waitingResults.count > 0 {
                    if let tabItems = self.tabBarController?.tabBar.items {
                        let tabItem = tabItems[1]
                        tabItem.badgeValue = String(self.waitingResults.count)
                    }
                }
                else{
                    if let tabItems = self.tabBarController?.tabBar.items {
                        let tabItem = tabItems[1]
                        tabItem.badgeValue = nil
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.waitingResults.count > 0{
                return self.waitingResults.count
            }
            else{
                return 1
            }
        } else if section == 1 {
            if self.pastResults.count > 0{
                return self.pastResults.count
            }
            else{
                return 1
            }
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label : UILabel = UILabel()
        
        if (section == 0){
            label.text = "  " + "Waiting for response"
        }
        else{
            label.text = "  " + "Past Results"
        }
        
        label.backgroundColor = UIColor.init(displayP3Red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return label
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell

        if indexPath.section == 0{
            if waitingResults.count > 0{
                cell.titleLabel.isHidden = false
                cell.dateLabel.isHidden = false
                cell.locationLabel.isHidden = false
                cell.titleLabel.text = self.waitingResults[indexPath.row].search
                cell.dateLabel.text = self.waitingResults[indexPath.row].data
                cell.locationLabel.text = self.waitingResults[indexPath.row].location
                cell.requestsLabel.text = self.waitingResults[indexPath.row].uid
                cell.searchLabel.text = self.waitingResults[indexPath.row].result
                cell.requestsLabel.isHidden = true
            }
            else{
                cell.titleLabel.isHidden = true
                cell.dateLabel.isHidden = true
                cell.locationLabel.isHidden = true
                cell.requestsLabel.isHidden = false
                cell.requestsLabel.text = "You don't have any requests."
            }
        }
        else{
            if pastResults.count > 0{
                cell.titleLabel.text = self.pastResults[indexPath.row].search
                cell.dateLabel.text = self.pastResults[indexPath.row].data
                cell.locationLabel.text = self.pastResults[indexPath.row].location
                cell.requestsLabel.text = self.pastResults[indexPath.row].uid
                cell.searchLabel.text = self.pastResults[indexPath.row].result
                cell.requestsLabel.isHidden = true
                cell.titleLabel.isHidden = false
                cell.dateLabel.isHidden = false
                cell.locationLabel.isHidden = false
            }else{
                cell.titleLabel.isHidden = true
                cell.dateLabel.isHidden = true
                cell.locationLabel.isHidden = true
                cell.requestsLabel.isHidden = false
                cell.requestsLabel.text = "You don't have any past results."
            }
        }
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pastResults.removeAll()
        self.waitingResults.removeAll()
        self.requests.removeAll()
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! HistoryCell
        self.uid = cell.searchLabel.text!
        print(self.uid)
        if cell.searchLabel.text != ""{
            self.performSegue(withIdentifier: "HSearch", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Hsearch" {
            let controller = segue.destination as! ResultViewController
            globalUid = self.uid
            controller.uid = self.uid
        }
    }
}

