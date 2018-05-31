//
//  Singleton.swift
//  Socialite
//
//  Created by user on 25/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    static let ds = DataService()
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_USER_UPLOADS = DB_BASE.child("userUploads")
    
    
    //Storage refernces
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-pics")
    
    var _POST_ID: FIRDatabaseReference!
    var _POST_KEY: String!
    
    
    var REF_BASE: FIRDatabaseReference {
            return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var POST_KEY: String! {
        return _POST_KEY
    }
    
    var POST_ID: FIRDatabaseReference {
        return _POST_ID
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_UPLOADS: FIRDatabaseReference {
        return _REF_USER_UPLOADS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var USER_ID: String {
        let userRef = "\(DataService.ds.REF_USER_CURRENT)"
        let userId = userRef.replacingOccurrences(of: "https://projectapp-a3e91.firebaseio.com/users/", with: "")
        return userId
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: FIRStorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    func createFirbaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
        
    }
 
}
