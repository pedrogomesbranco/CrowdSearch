//
//  User.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 04/09/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject{
    var email: String? = ""
    var location: String? = ""
    var uid: String? = ""
    var lat: Double? = 0.0
    var lon: Double? = 0.0

    
    func save(){
        let ref = DataBaseReference.users(uid: uid!).reference()
        ref.setValue(toDictionary())
    }
    
    func toDictionary() -> [String: Any]{
        return [
            "uid" : uid as Any,
            "email" : email as Any,
            "location" : location as Any,
            "lat": lat as Any,
            "lon" : lon as Any
        ]
    }
}
