//
//  SearchCell.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 20/07/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setSearch(text: String?, placeholder: String) {
        searchTextField.text = text
        searchTextField.placeholder = placeholder
        
        searchTextField.accessibilityValue = text
        searchTextField.accessibilityLabel = placeholder
    }
    
    func setLocation(text: String?, placeholder: String) {
        locationTextField.text = text
        locationTextField.placeholder = placeholder
        
        locationTextField.accessibilityValue = text
        locationTextField.accessibilityLabel = placeholder
    }
}
