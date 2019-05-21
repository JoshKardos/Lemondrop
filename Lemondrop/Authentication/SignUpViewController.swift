//
//  ViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/16/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
class SignUpViewController: UIViewController {
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
        } else {
            
            print("Not logged in")
        }
    }
    @IBAction func registerPressed(_ sender: Any) {
        
        if validTextFields(){
            
            
            ProgressHUD.show("Waiting...", interaction: false)
            
            AuthService.signUp(fullname: fullNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, school: schoolTextField.text!, age: ageTextField.text!, onSuccess:{
                
                ProgressHUD.showSuccess("Success")
                self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
            }, onError: {errorString in
                
                ProgressHUD.showError(errorString!)
            })
        }  else {
            ProgressHUD.showError("There are empty fields...")
        }
        
        
    }
    
    
    
    
    func validTextFields() -> Bool{
        
        //        invitation.range(of: #"\bClue(do)?™?\b"#, options: .regularExpression) != nil // true
        //first name --> "^[a-z]{1,10}$"  last name --> "^[a-z'\\-]{2,20}$",
        
        if !fullNameTextField.text!.isEmpty && !ageTextField.text!.isEmpty && !schoolTextField.text!.isEmpty && !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty{
            
            return true
            
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

