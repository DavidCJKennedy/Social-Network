//
//  settingsVC.swift
//  Socialite
//
//  Created by user on 23/10/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import Firebase

class settingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePictureImg: UIImageView!
    @IBOutlet weak var userNameField: MaterialTextField!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    //var profileImg: UIImage!
    //var userName: String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        profilePictureImg.layer.cornerRadius = 75.00
        profilePictureImg.clipsToBounds = true

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePictureImg.image = image
            imageSelected = true
        } else {
            print("An invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func changePictureTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func updateProfileTapped(_ sender: AnyObject) {
        
        guard let _ = userNameField.text, userNameField.text != "" else {
            return
        }
        
        guard let profileImg = profilePictureImg.image, imageSelected == true else {
            return
        }
        
        
        DataService.ds.REF_USER_CURRENT.child("userInfo/profilePictureId").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let imgRef = snapshot.value!
            print("DAVIDKE: \(imgRef)")
            
            let storage = FIRStorage.storage()
            let imgStorageRef = storage.reference(withPath: "/profile-pics/\(imgRef)")
            print("DAVIDKE: \(imgStorageRef)")
            imgStorageRef.delete { (error) -> Void in
                if error != nil {
                    print("DAvid: File not deleted")
                } else {
                    print("David: File Deleted")
                }
            }
        })
        
        
        if let imgData = UIImageJPEGRepresentation(profileImg, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                print("Unable to upload image to Firbase storage")
                } else {
                    print("Successfully uploaded profile image")
                    self.imageSelected = false
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postDataToFireBase(imgUid: imgUid, imgUrl: url)
//                        let user = FIRAuth.auth()?.currentUser
//                        if let user = user {
//                            let changeRequest = user.profileChangeRequest()
//                            
//                            changeRequest.displayName = userName
//                            print("DAVID:\(changeRequest.displayName)")
//                            changeRequest.photoURL = NSURL(string: url) as URL?
//                            print("DAVID:\(changeRequest.photoURL)")
//                            changeRequest.commitChanges(completion: { error in
//                                if let error = error {
//                                    print("Error occured in profile update \(error)")
//                                } else {
//                                    print("Profile updated")
//                                }
//                            })
//                        }
                    }
                }
            }
        }
        performSegue(withIdentifier: "updateBtnPressed", sender: nil)
    }
    
    func postDataToFireBase(imgUid: String, imgUrl: String) {
        let data: Dictionary<String, Any> = [
            "userName": userNameField.text! as String,
            "profilePictureId": imgUid as String,
            "profilePictureUrl" : imgUrl as String
        ]
        
        let firebaseUser = DataService.ds.REF_USER_CURRENT.child("userInfo")
        firebaseUser.setValue(data)
    }


    
    @IBAction func onCancelTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "cancelBtnPressed", sender: nil)
    }

}
