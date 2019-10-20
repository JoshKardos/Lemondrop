//
//  ChangePasswordViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import ProgressHUD
class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func acceptPressed(_ sender: Any) {
        
        //validate
        
        let emailString = (Auth.auth().currentUser?.email)!
        let passwordString = oldPasswordTextField.text!
        
        //compare new passwords agaisnt eachother
        if newPasswordTextField.text != confirmNewPasswordTextField.text {
            ProgressHUD.showError("The new password fields are different...")
            return
        }
        //
        
        //check that this is the correct old password
        
//        let credential = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: oldPasswordTextField.text!)
//        //https://stackoverflow.com/questions/38253185/re-authenticating-user-credentials-swift
//
//
//        user?.reauthenticate(with: credential, completion: { (result, error) in
//
//            if error != nil {
//                ProgressHUD.showError("The password is invalid")
//                return
//            }
//
        AuthService.reauthenticateUser(email: emailString, password: passwordString, onSuccess: {
            
            Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!) { (error) in
                
                if error != nil{
                    
                    print("Error changing password")
                    ProgressHUD.showError("\((error?.localizedDescription)!)")
                    return
                    
                } else {
                    
                    ProgressHUD.showSuccess("Password changed")
                    return
                }
                
            }
            
        }) { error in
            ProgressHUD.showError(error)
        }
        
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
