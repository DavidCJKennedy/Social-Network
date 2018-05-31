//
//  CommentCell.swift
//  Socialite
//
//  Created by user on 21/11/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentNameLbl: UILabel!
    @IBOutlet weak var commentPictureImg: UIImageView!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var postId: FIRDatabaseReference!
    var post: Post!
    var comments = [Post]()
    var authorImgUrl: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.child("comments").observe(.value, with: { (snapshot) in
            
            self.comments = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("Snaper: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let comment = Post(postKey: key, postData: postDict)
                        self.comments.append(comment)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? PostCell {
            if let img = FeedVC.commentAuthorCache.object(forKey: post.commentUserImgUrl as NSString){
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post, img: nil)
                return cell
            }
        } else {
            return CommentCell()
        }
    
    }
    
    
    
    func configureComments(post: Post, img: UIImage? = nil) {
        self.post = post
        self.postId = post.postRef
        self.commentText.text = post.commentCaption
        
        let commentsRef = DataService.ds.REF_POSTS.child("\(self.postId)").child("comments")
        commentsRef.child("authorId").observeSingleEvent(of: .value, with: { (snapshot) in
            let authorId = snapshot.value
            print("DAVIDKENNEDY:\(authorId)")
            DataService.ds.REF_USERS.child("\(authorId!)").child("userInfo").child("profilePictureUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                self.authorImgUrl = snapshot.value as! String
                print("DAVIDKENNEDY:\(self.authorImgUrl)")
                let ref = FIRStorage.storage().reference(forURL: self.authorImgUrl as String)
                ref.data(withMaxSize: 500*1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to download image from firebase storage")
                    } else {
                        print("Image downloaded from firbase stroage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.commentPictureImg.image = img
                                FeedVC.commentAuthorCache.setObject(img, forKey: post.commentUserImgUrl as NSString)
                            }
                        }
                    }
                })
            })
        })
        

        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
