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
    }
    
    
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        print("LOGOUT PRESSD")
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
            
            self.logoutConfirmPressed()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func logoutConfirmPressed(){
        
        AuthService.logout(sender: nil)
        self.dismiss(animated: false) 
    }
    
}
