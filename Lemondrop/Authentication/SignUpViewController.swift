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
import FirebaseDatabase
class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var validatePasswordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyMemberButton: UIButton!
    
    @IBOutlet weak var fullnameActivityBar: UIActivityIndicatorView!
    
    @IBOutlet weak var fullnameWarningLabel: UILabel!
    var fullNameIsUnique = true
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.fullnameActivityBar.isHidden = true
        fullNameTextField.addTarget(self, action: #selector(fullNameFieldDidChange(_:)), for: .editingChanged)
        
        fullNameTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBOutlet weak var alreadyMembarBottomConstraint: NSLayoutConstraint!
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            
//        }
        
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        
//        if let origin = origin {
//
//            self.view.frame.origin.y = origin
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        if Auth.auth().currentUser != nil {
//            AuthService.setToken()
            AuthService.addPlayerId()
            self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
        }
        
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        
        if passwordTextField.text != validatePasswordTextField.text {
            ProgressHUD.showError("Passwords Must Match")
            return
        }
        
        if self.fullNameIsUnique{
            if validTextFields(){
                
                
                ProgressHUD.show("Waiting...", interaction: false)
                
                
                
                AuthService.signUp(fullname: self.fullNameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!,  onSuccess:{
                    
                    ProgressHUD.showSuccess("Success")
                    self.performSegue(withIdentifier: "showDetailMapView", sender: nil)
                }, onError: {errorString in
                    
                    ProgressHUD.showError(errorString!)
                })
                
                
            }  else {
                ProgressHUD.showError("There are empty fields...")
            }
        } else {
            ProgressHUD.showError("Must Have a Unique Fullname to Register")
        }
        
        
        
        
        
    }
    var timer: Timer?
    @objc func handleAnimation(){
        DispatchQueue.main.async {
            self.fullnameActivityBar.stopAnimating()
            self.fullnameActivityBar.isHidden = true
        }
    }
    @objc func fullNameFieldDidChange(_ textField: UITextField) {
        checkIsUniqueFullname { (bool) in
            
            self.fullnameActivityBar.isHidden = false
            self.fullnameActivityBar.startAnimating()
            if bool{
                self.fullNameTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
                self.fullNameTextField.layer.borderWidth = 0.0
                self.fullNameIsUnique = true
                self.fullnameWarningLabel.isHidden = true
                print(true)
                
                
            } else {
                self.fullNameTextField.layer.borderWidth = 2.0
                self.fullNameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                self.fullNameIsUnique = false
                
                self.fullnameWarningLabel.text = "Fullname must be unique"
                self.fullnameWarningLabel.isHidden = false
                print(false)
                
                
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleAnimation), userInfo: nil, repeats: false)
        }
    }
    
    
    func checkIsUniqueFullname(completion: @escaping (Bool)->()){
        
        Database.database().reference().child(FirebaseNodes.fullnames).observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String: Any] {
                for (name, _) in dict {
                    
                    if name == self.fullNameTextField.text{
                        completion(false)
                        return
                    }
                    
                }
                completion(true)
            }
        }
        
        completion(true)
        
    }
    
    
    func validTextFields() -> Bool{
        
        //        invitation.range(of: #"\bClue(do)?™?\b"#, options: .regularExpression) != nil // true
        //first name --> "^[a-z]{1,10}$"  last name --> "^[a-z'\\-]{2,20}$",
        
        if !fullNameTextField.text!.isEmpty &&  !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty{
            
            return true
            
        }
        
        return false
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(true)
//    }
    
}

