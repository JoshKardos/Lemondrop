//
//  ChangeEmailViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    @IBAction func acceptPressed(_ sender: Any) {
        
        
        let newEmailString = emailTextField.text!
        let oldEmailString = (Auth.auth().currentUser?.email)!
        let passwordString = passwordTextField.text!
        
        AuthService.reauthenticateUser(email: oldEmailString, password: passwordString, onSuccess: {
            
            
            Auth.auth().currentUser?.updateEmail(to: newEmailString) { (error) in
                if error != nil{
                    ProgressHUD.showError("\(error?.localizedDescription)")
                    
                    return
                }
                
                
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["email": newEmailString])
                ProgressHUD.showSuccess("Email successfully changed... Now you will be signed out")
                
                AuthService.logout(sender: nil)
                self.dismiss(animated: true, completion: nil)
            
                
                
            }
            
            
        }) { (error) in
            ProgressHUD.showError(error)
        }
        
        
        
        
        
    }
    @IBAction func denyPressed(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
}
