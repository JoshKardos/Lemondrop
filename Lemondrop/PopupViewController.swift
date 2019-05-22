//
//  PopupViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import Alamofire

class PopupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var standNameTextField: UITextField!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    var delegate: MapViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        container.layer.cornerRadius = 12
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        priceTextField.delegate = self
        disableSubmitButton()
        
        standNameTextField.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                     for: UIControl.Event.editingChanged)
        priceTextField.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                 for: UIControl.Event.editingChanged)
        
        startTimePicker.minimumDate = Date()
        startTimePicker.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                  for: UIControl.Event.valueChanged)
        endTimePicker.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                for: UIControl.Event.valueChanged)
        
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if !standNameTextField.text!.isEmpty && !priceTextField.text!.isEmpty && endTimePicker.date > startTimePicker.date {
            enableSubmitButton()
            print("ENABLED")
        } else {
            disableSubmitButton()
            print("DISABLED")
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        //        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: nil, userInfo: nil, repeats: true)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            self.view.removeFromSuperview()
        }
        
        
        
        
    }
    @IBAction func submitPressed(_ sender: Any) {
        
        
        
        if let price = Double(priceTextField.text!) {
            if price <  0.01 {
                ProgressHUD.showError("Can't get smaller than a penny")
                return
            }
        } else {
            ProgressHUD.showError("Not a valid price set")
            return
        }
        if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Internet connection failure")
            return
        }
        
        let newStandRef = Database.database().reference().child("activeLemonadeStands").childByAutoId()
        let newStandRefId = newStandRef.key
        
        
        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value) { (snapshot) in
                if let user = snapshot.value as? NSDictionary{
                    newStandRef.setValue(["standId": newStandRefId!, "latitude": self.delegate!.currentLocation!.coordinate.latitude, "longitude": self.delegate!.currentLocation?.coordinate.longitude, "standName": self.standNameTextField.text!,"startTime": self.startTimePicker.date.timeIntervalSince1970 ,"endTime": self.endTimePicker.date.timeIntervalSince1970,"pricePerGlass": self.priceTextField.text!, "userID": (Auth.auth().currentUser?.uid)!, "creatorFullname": user["fullname"]]){ (error, ref) in
                                //it's okay to store the  user's fullname in the stand node becuase the stands don't
                                //have a long lifetime, its not like a soicla media post
                                if error != nil{
                                    
                                    ProgressHUD.showError("Failure saving to our records...")
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    
                                } else {
                                    ProgressHUD.showSuccess("Success!")
                                    self.view.removeFromSuperview()
                                    self.delegate?.reload()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                                UIApplication.shared.endIgnoringInteractionEvents()
                                return
                            }
                        
                }
            }
            UIApplication.shared.endIgnoringInteractionEvents()
            
            
            
        }
    }
    
    
    
    func disableSubmitButton(){
        submitButton.isEnabled = false
        submitButton.setTitleColor(UIColor.gray, for: .normal)
    }
    func enableSubmitButton(){
        submitButton.isEnabled = true
        submitButton.setTitleColor(UIColor.green, for: .normal)
    }
    
}


struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
