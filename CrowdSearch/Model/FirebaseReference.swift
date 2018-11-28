//
//  FirebaseReference.swift
//  CrowdSearch
//
//  Created by Pedro G. Branco on 09/11/18.
//  Copyright © 2018 Pedro G. Branco. All rights reserved.
//

import Foundation
import Firebase

enum DataBaseReference{
    case root
    case users(uid: String)
    
    func reference() -> DatabaseReference{
        switch self {
        case .root:
            return rootRef
        default:
            return rootRef.child(path)
        }        
    }
    
    private var rootRef: DatabaseReference{
        return Database.database().reference()
    }
    
    private var path: String{
        switch self {
        case .root:
            return ""
        case .users(let uid):
            return "users/\(uid)"
        }
    }
}
