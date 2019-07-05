//
//  SignInViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseAuth
import ProgressHUD
import UserNotifications

class SignInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        handleTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
        }
    }
    func handleTextField(){
        emailTextField.addTarget(self, action:#selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action:#selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            
            signInButton.isEnabled = false
            return
        }
        signInButton.isEnabled = true
    }
    
    @IBAction func signInButton(_ sender: Any) {
        
        
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess:{
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
            
        }, onError: { errorString in
            
            ProgressHUD.showError("Invalid email/password combination")
        })
    }
}
