//
//  EditProfileViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseAuth
class EditProfileViewController: UIViewController {
    
    
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    
    var fullnameIsUnique = true
    @IBOutlet weak var fullnameActivityBar: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fullnameTextField.text = MapViewController.currentUser.fullname!
        
        // Do any additional setup after loading the view.
        fullnameActivityBar.isHidden = true
        fullnameTextField.addTarget(self, action: #selector(fullNameFieldDidChange(_:)), for: .editingChanged)
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
                self.fullnameTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
                self.fullnameTextField.layer.borderWidth = 0.0
                self.fullnameIsUnique = true
                print(true)
                
                
            } else {
                self.fullnameTextField.layer.borderWidth = 2.0
                self.fullnameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                self.fullnameIsUnique = false
                
                print(false)
                
                
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleAnimation), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        
        if !self.validTextFields(){
            return
        }
        
        let oldFullname = MapViewController.currentUser.fullname
        
        ProgressHUD.show()
        var values = ["fullname": fullnameTextField.text!]
        if schoolTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            values["school"] = schoolTextField.text!
        }
        if ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            
            values["age"] = ageTextField.text!
        }
        Database.database().reference().child(FirebaseNodes.users).child((Auth.auth().currentUser?.uid)!).updateChildValues(values) { (error, ref) in
            if error == nil {
                
                //delete old username from database
                Database.database().reference().child(FirebaseNodes.fullnames).child(oldFullname!).removeValue()
                Database.database().reference().child(FirebaseNodes.fullnames).child(self.fullnameTextField.text!).setValue(1)
                
                MapViewController.reloadCurrentUser()
                ProgressHUD.showSuccess("Successfully changed your information")
                
            } else {
                ProgressHUD.showError("Could not update your records")
            }
        }
        
        
        
    }
    
    func checkIsUniqueFullname(completion: @escaping (Bool)->()){
        
        Database.database().reference().child(FirebaseNodes.fullnames).observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String: Any] {
                for (name, _) in dict {
                    
                    if name == self.fullnameTextField.text && name != MapViewController.currentUser.fullname!{
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
        
        if !fullnameIsUnique{
            ProgressHUD.showError("Username must be unique")
            return false
        }
        
        if fullnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            ProgressHUD.showError("Must not have an empty field")
            return false
        }
        
        return true
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
