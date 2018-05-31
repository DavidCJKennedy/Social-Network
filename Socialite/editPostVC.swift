//
//  editPostVC.swift
//  Socialite
//
//  Created by user on 18/11/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import Firebase

class editPostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var captionText: UITextView!
    @IBOutlet weak var postImg: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var postId = "\(DataService.ds._POST_ID!)"
    var postKey = DataService.ds._POST_KEY!
    var imgUrl: String!
    var imgId: String!
    var complete = false
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        postImg.layer.cornerRadius = 75.00
        postImg.clipsToBounds = true
        
        var imgIdHandle: UInt = 0
        let imgIdRef = DataService.ds._POST_ID.child("imageId")
        imgIdHandle = imgIdRef.observe(.value, with: { (snapshot) in
        
            self.imgId = "\(snapshot.value!)"
            print("DAVID: \(self.imgId!)")
        })
        configurePage()
        imgIdRef.removeObserver(withHandle: imgIdHandle)
        
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image  = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImg.image = image
        } else {
            print("invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func configurePage() {
        
        let ref = DataService.ds._POST_ID.child("caption")
        var handle: UInt = 0
        handle = ref.observe(.value, with: { snapshot in
            print(snapshot)
            if snapshot.exists() && snapshot.value as! String == "42" {
                print("The value is now 42")
                ref.removeObserver(withHandle: handle)
            }
        })
        
        var textHandle: UInt = 0
        var imgHandle: UInt = 0
            let textRef = DataService.ds._POST_ID.child("caption")
            textHandle = textRef.observe(.value, with: { (snapshot) in
                print("DAVID:\(self.postId)")
                let text = snapshot.value!
                self.captionText.text = "\(text)"
                textRef.removeObserver(withHandle: textHandle)
            })
            let imgRef = DataService.ds._POST_ID.child("imageUrl")
            imgHandle = imgRef.observe(.value, with: { (snapshot) in
                if snapshot.exists() == true {
                    let imgUrl = snapshot.value!
                    print("DAVID:\(imgUrl)")
                    imgRef.removeObserver(withHandle: imgHandle)
                    
                    let ref = FIRStorage.storage().reference(forURL: imgUrl as! String)
                    ref.data(withMaxSize: 500 * 1024, completion: { (data, error) in //500kb
                        if error != nil {
                            print("Unable to download image from firebase storage")
                        } else {
                            print("Image downloaded from firbase stroage")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    self.postImg.image = img
                                }
                            }
                        }
                    })
                    
                }})
    }

    @IBAction func changeImgTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func updateBtnTapped(_ sender: AnyObject) {
        
        DataService.ds._POST_ID.child("imageId").observeSingleEvent(of: .value, with: { (snapshot) in
            let imgRef = snapshot.value!
            print("DAVIDKE: \(imgRef)")
            
            let storage = FIRStorage.storage()
            let imgStorageRef = storage.reference(withPath: "/post-pics/\(imgRef)")
            print("DAVIDKE: \(imgStorageRef)")
            imgStorageRef.delete { (error) -> Void in
                if error != nil {
                    print("DAvid: File not deleted")
                } else {
                    print("David: File Deleted")
                }
            }
        })
        
        let newImg = postImg.image
        if let imgData = UIImageJPEGRepresentation(newImg!, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("Unable to upload image to Firbase storage")
                } else {
                    print("Successfully uploaded profile image")
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                    DataService.ds._POST_ID.child("imageUrl").setValue("\(downloadUrl!)")
                    DataService.ds._POST_ID.child("imageId").setValue("\(imgUid)")
                    }
                }
            
        }
        let newCaption = captionText.text
        DataService.ds._POST_ID.child("caption").setValue("\(newCaption!)")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePostBtnTapped(_ sender: AnyObject) {
        deleteImg()
    }
    
    func deleteImg() {
        let imgStorage = FIRStorage.storage().reference(withPath: "/post-pics/\(self.imgId!)")
        print("DAVIDKENNE:\(imgStorage)")
        imgStorage.delete { (error) -> Void in
            if error != nil {
                print("DAVIDKENNED: file not deleted")
                self.complete = true
            } else {
                print("DAVIDKENNED: file deleted")
                self.complete = true
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(deleteData), userInfo: nil, repeats: false)
    }
    
    func deleteData() {
        DataService.ds.REF_USER_CURRENT.child("posts").child("\(postKey)").removeValue()
        print("DAVIDKEN: \(DataService.ds.REF_USER_CURRENT.child("posts").child("\(postKey)"))")
        
        DataService.ds._POST_ID.removeValue()
        
        self.captionText.text = ""
        self.postImg.image = #imageLiteral(resourceName: "userImg 2")
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
