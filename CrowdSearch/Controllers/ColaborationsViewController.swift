//
//  ColaborationViewController.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire

class ColaborationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
        
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [Requests]()
    var pastResults = [Requests]()
    var waitingResults = [Requests]()
    var results = [Result]()
    var uid = ""
    let defaults = UserDefaults.standard

    
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
    }
    
    func fetchData(){
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

                print(request.uid)
                self.requests.append(request)
                
                if request.toId == Auth.auth().currentUser?.uid{
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
                        let tabItem = tabItems[2]
                        tabItem.badgeValue = String(self.waitingResults.count)
                    }
                }
                else{
                    if let tabItems = self.tabBarController?.tabBar.items {
                        let tabItem = tabItems[2]
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
            label.text = "  " + "Requests for your location"
        }
        else{
            label.text = "  " + "Past Colaborations"
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
                cell.searchLabel.text = self.waitingResults[indexPath.row].result
                cell.titleLabel.text = self.waitingResults[indexPath.row].search
                cell.dateLabel.text = self.waitingResults[indexPath.row].data
                cell.locationLabel.text = self.waitingResults[indexPath.row].location
                cell.requestsLabel.text = self.waitingResults[indexPath.row].uid
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
    }
    
    func performSearch (query: String){
        
        let accessKey = "f8b2adac350a4e6f91516e139f1a1290"
        let search_url = "https://api.cognitive.microsoft.com/bing/v7.0/search"
        let headers = ["Ocp-Apim-Subscription-Key" : accessKey]
        let params :[String : Any] = ["q":query, "mkt":"pt-BR", "filterReuslts": "webpages", "count": 10]
        
        
        Alamofire.request(search_url, method: .get, parameters: params, encoding: Alamofire.URLEncoding.default ,headers: headers).validate().responseJSON { response in
            
            switch response.result {
            case .success (let JSON):
                print(response.result.value as Any)
                
                let resposta = JSON as! NSDictionary
                let newResposta = resposta["webPages"] as! NSDictionary
                let values = newResposta["value"] as! NSArray
                for i in 0...values.count-1{
                    let value = values[i] as! NSDictionary
                    let result = Result()
                    
                    result.name = (value["name"] as! String)
                    result.url = (value["url"] as! String)
                    result.snippet = (value["snippet"] as! String)
                    
                    self.results.append(result)
                }
                
                let ref1 = DataBaseReference.root.reference().child("result")
                let childRef = ref1.childByAutoId()
                
                for i in 0...self.results.count-1{
                    let values = ["name\(i)": self.results[i].name, "url\(i)": self.results[i].url, "snnipet\(i)": self.results[i].snippet] as! [NSString: NSString]
                    childRef.updateChildValues(values)
                }
                
                let ref2 = DataBaseReference.root.reference().child("requests").child(self.uid )
                let newvalue = ["result": childRef.key]
                ref2.updateChildValues(newvalue as [AnyHashable : Any])
                
                self.pastResults.removeAll()
                self.waitingResults.removeAll()
                self.requests.removeAll()
                self.fetchData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! HistoryCell
        if cell.searchLabel.text != ""{
            self.uid = cell.searchLabel.text!
            defaults.set(self.uid, forKey: "uid")
            self.performSegue(withIdentifier: "HSearch", sender: self)
        }
        else{
            self.uid = cell.requestsLabel.text!
            defaults.set(self.uid, forKey: "uid")
            for i in requests{
                if i.uid == cell.requestsLabel.text{
                    performSearch(query: cell.titleLabel.text!)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Hsearch" {
            let controller = segue.destination as! ResultViewController
        }
    }
}

