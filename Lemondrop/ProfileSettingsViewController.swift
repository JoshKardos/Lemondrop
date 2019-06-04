//
//  ProfileSettingsViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/27/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseAuth
class ProfileSettingsViewController: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        

    }
    @IBAction func logoutPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
            AuthService.logout(sender: self)}))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        AuthService.logout(sender: self)//logout()
    }
    
}
