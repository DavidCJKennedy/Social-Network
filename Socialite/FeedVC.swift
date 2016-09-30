//
//  FeedVC.swift
//  Socialite
//
//  Created by user on 25/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { FIRDataSnapshot in
            if let snapshot = FIRDataSnapshot.children.allObjects as? [FIRStorageTaskSnapshot] {
                for snap in snapshot {
                    print("Snap: \(snap)")
//                    if let postDict = snap.valueForKey(<#T##key: String##String#>) as? Dictionary<String, AnyObject> {
//                        let key = snap.key
                    
//                    }
                }
            }
        })

        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
    }

    @IBAction func onSignOutTapped(sender: AnyObject) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("Removed Id from key chain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegueWithIdentifier("goToSignIn", sender: nil)
    }

}
