//
//  Post.swift
//  Socialite
//
//  Created by user on 30/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _userId: String!
    private var _imageId: String!
    private var _commentCaption: String!
    private var _commentUserId: String!
    private var _commentUserImgUrl: String!
    
    var userId: String{
        return _userId
    }
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int! {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var postRef: FIRDatabaseReference {
        return _postRef
    }
    
    var commentCaption: String {
        return _commentCaption
    }
    
    var commentUserId: String {
        return _commentUserId
    }
    
    var commentUserImgUrl: String {
        return _commentUserImgUrl
    }
    
    init(commentCaption: String, commentUserId: String, commentUserImgUrl: String) {
        self._commentCaption = commentCaption
        self._commentUserId = commentUserId
        self._commentUserImgUrl = commentUserImgUrl
    }
    
    
    init(caption: String, imageUrl: String, likes: Int, userId: String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._userId = userId
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userId = postData["authorId"] as? String {
            self._userId = userId
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
    }
    
    
    
}
