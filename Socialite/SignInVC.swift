//
//  ViewController.swift
//  Socialite
//
//  Created by user on 24/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
        //if let _ = KeychainWrapper.defaultKeychainWrapper.stringForKey(KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginBtnTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("User authenticated wth firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase")
                        } else {
                            print("Successfully authenticated with firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                            
                            }
                    })
                }
        })
    }
}
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        print("DAVID: \(KeychainWrapper.standard.hasValue(forKey: KEY_UID))")
        
        if KeychainWrapper.standard.hasValue(forKey: KEY_UID) == false {
            let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
            print("Data saved to keychain \(keychainResult)")
            performSegue(withIdentifier: "goToSettings", sender: nil)
        } else {
            let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
            print("Data saved to keychain \(keychainResult)")
            performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    }
}
