//
//  Result.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 25/11/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import Foundation

class Result: NSObject {
    var url: String? = ""
    var name: String? = ""
    var snippet: String? = ""
    
    func toDictionary() -> [String: Any]{
        return [
            "name" : name as Any,
            "url" : url as Any,
            "snippet" : snippet as Any
        ]
    }
}
