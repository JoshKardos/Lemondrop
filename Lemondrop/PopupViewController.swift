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
import SwiftyJSON
class PopupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var standNameTextField: UITextField!
    static var standCreated = false
    @IBOutlet weak var reopenStandButton: UIButton!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    var delegate: MapViewController?
    var cityName: String?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        PopupViewController.standCreated = false
        container.layer.cornerRadius = 12
        reopenStandButton.layer.cornerRadius = 12
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        priceTextField.delegate = self
        disableSubmitButton()
        
        standNameTextField.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                     for: UIControl.Event.editingChanged)
        priceTextField.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                 for: UIControl.Event.editingChanged)
        priceTextField.addTarget(self, action: #selector(priceTextFieldDidChange), for: .editingChanged)

        startTimePicker.minimumDate = Date()
        endTimePicker.minimumDate = startTimePicker.date
        
        startTimePicker.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                  for: UIControl.Event.valueChanged)
        endTimePicker.addTarget(self, action: #selector(PopupViewController.textFieldDidChange(_:)),
                                for: UIControl.Event.valueChanged)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if PopupViewController.standCreated{
            view.removeFromSuperview()
            self.delegate?.reload()
        }
        
    }
    @objc func priceTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        startTimePicker.maximumDate = endTimePicker.date
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
        
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            
            self.view.removeFromSuperview()
        }
        
        
        
        
    }
    @IBAction func submitPressed(_ sender: Any) {
        
        
        priceTextField.text?.removeFirst()
        
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
    
        let alert = UIAlertController(title: "ATTENTION!", message: "Confirm that somebody 18 or older will be with you at this Stand", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Default action"), style: .default, handler: { _ in
            self.getCityName {
                self.saveLemonadeStand()
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            ProgressHUD.showError("DENIED, must have an adult with you")
            alert.removeFromParent()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveLemonadeStand(){
        
        let newStandRef = Database.database().reference().child(FirebaseNodes.stands).childByAutoId()
        let newStandRefId = newStandRef.key
        
        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            Database.database().reference().child(FirebaseNodes.users).child((Auth.auth().currentUser?.uid)!).observe(.value) { (snapshot) in
                if let user = snapshot.value as? NSDictionary{
                    newStandRef.setValue(["standId": newStandRefId!, "latitude": MapViewController.currentLocation!.coordinate.latitude, "longitude": MapViewController.currentLocation?.coordinate.longitude, "standName": self.standNameTextField.text!,"startTime": self.startTimePicker.date.timeIntervalSince1970 ,"endTime": self.endTimePicker.date.timeIntervalSince1970,"pricePerGlass": self.priceTextField.text!, "userID": (Auth.auth().currentUser?.uid)!, "creatorFullname": user["fullname"], "city": self.cityName!]){ (error, ref) in
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
    func getCityName(completion: @escaping () -> Void){
        guard let url = URL(string:  "https://maps.googleapis.com/maps/api/geocode/json?latlng=\((MapViewController.currentLocation?.coordinate.latitude)!),\((MapViewController.currentLocation?.coordinate.longitude)!)&key=\(ApiKeys.googleMapsApiKey)") else {
            completion()
            return
        }
        print(url)
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let googleJSON : JSON = JSON(response.result.value!)
                    print(googleJSON["results"][0]["address_components"][3]["long_name"])
                    self.cityName = googleJSON["results"][0]["address_components"][3]["long_name"].string
                    completion()
                    return
                } else {
                    ProgressHUD.showError("Error fetching location data")
                }
        }
        
        
        
        
    }
    
    @IBAction func reopenStandPressed(_ sender: Any) {
        
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserStands") as! ClickableUserStandsTableViewController
        view.navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(view, animated: true)
        
        
    }
}


struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
