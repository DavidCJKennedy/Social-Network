//
//  PostCell.swift
//  Socialite
//
//  Created by user on 26/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showCaseImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var editBtn: MaterialButton!
    @IBOutlet weak var commentField: MaterialTextField!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var postAuthor: String!
    var postId: FIRDatabaseReference!
    var postKey: String!
    var commentId: String!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes!)"
        self.postAuthor = post.userId
        postId = post.postRef
        postKey = post.postKey
        print("DAVID\(post.postRef)")
        
        if post.userId == String(describing: FIRAuth.auth()!.currentUser!.uid) {
            editBtn.isHidden = false
        } else {
            editBtn.isHidden = true
        }
        
        print("DAVID\(post.userId)")
        print("DAVID\(String(describing: FIRAuth.auth()!.currentUser!.uid))")
        
        let userRef = DataService.ds.REF_USERS.child("\(self.postAuthor!)").child("userInfo")
        
        userRef.child("userName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.usernameLbl.text = String(describing: snapshot.value!)
            print("DAVIDKEN: \(self.usernameLbl.text)")
            })
        
        userRef.child("profilePictureUrl").observeSingleEvent(of: .value, with: { (snapshot) in
            let userImgRef = snapshot.value!
            print("DAVID: \(userImgRef)")
            
                let ref = FIRStorage.storage().reference(forURL: userImgRef as! String)
                ref.data(withMaxSize: 500 * 1024, completion: { (data, error) in //500kb
                    if error != nil {
                        print("Unable to download image from firebase storage")
                    } else {
                        print("Image downloaded from firbase stroage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.profileImg.image = img
                                FeedVC.profilePicCache.setObject(img, forKey: post.imageUrl as NSString)
                                
                            }
                        }
                    }
                })
            })
        
        
        if img != nil {
            self.showCaseImg.image = img
        } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                ref.data(withMaxSize: 500 * 1024, completion: { (data, error) in //500kb
                    if error != nil {
                        print("Unable to download image from firebase storage")
                    } else {
                        print("Image downloaded from firbase stroage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.showCaseImg.image = img
                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }

            likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likeImg.image = UIImage(named: "heart-empty")
                } else {
                    self.likeImg.image = UIImage(named: "heart-full")
                }
            })
        
        }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
        
    }
    
    @IBAction func onAddCommentBtnTapped(_ sender: AnyObject) {
        guard let commentCaption = commentField.text, commentCaption != "" else {
            print("Caption must be entered")
            return
        }
        
        let authorId = FIRAuth.auth()?.currentUser?.uid
        print("DavidKENNE: \(authorId)")
        let commentId = NSUUID().uuidString
        DataService.ds._POST_ID = postId
        postToFirebase(commentId: commentId, authorId: authorId!)
    }
    
    func postToFirebase(commentId: String, authorId: String) {
        let post: Dictionary<String, Any> = [
        "caption": commentField.text! as String,
        "authorId": authorId as String
        ]
        
        print("DAVIDKENNED:\(commentId)")
        
        let firebasePost = DataService.ds._POST_ID.child("comments").child("\(commentId)")
        firebasePost.setValue(post)
        
        let postRef = DataService.ds.REF_USER_UPLOADS.child(authorId).child("\(commentId)")
        postRef.setValue(true)
        
        commentField.text = " "
        
    }
    
    
    @IBAction func editBtnTapped(_ sender: AnyObject) {
        DataService.ds._POST_ID = postId
        DataService.ds._POST_KEY = postKey
        print("DAVID: \(DataService.ds._POST_ID!)")
    }
    
    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showCaseImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
