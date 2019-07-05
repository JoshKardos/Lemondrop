//
//  SetEndTimePopupViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/28/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseAuth

class SetEndTimePopupViewController: UIViewController {
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    var stand: LemonadeStand!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        container.layer.cornerRadius = 12
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        endTimePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func confirmButtonPressed(_ sender: Any) {
        reopenStand(stand: stand!, endAt: endTimePicker.date)
        
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            
            self.view.removeFromSuperview()
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func reopenStand(stand: LemonadeStand, endAt withDate: Date){
        
        let newRef = Database.database().reference().child("activeLemonadeStands").childByAutoId()
        
        let newStand = LemonadeStand(otherStand: stand, id: newRef.key!)
        
        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            newRef.setValue(["standId": newRef.key!, "latitude": newStand.latitude, "longitude": newStand.longitude, "standName": newStand.standName!,"startTime": Date().timeIntervalSince1970 ,"endTime": withDate.timeIntervalSince1970,"pricePerGlass": String(newStand.pricePerGlass!), "userID": (Auth.auth().currentUser?.uid)!, "creatorFullname": newStand.creatorName!, "city": newStand.city!]){ (error, ref) in
                //it's okay to store the  user's fullname in the stand node becuase the stands don't
                //have a long lifetime, its not like a soicla media post
                if error != nil{
                    
                    ProgressHUD.showError("Failure saving to our records...")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                } else {
                    ProgressHUD.showSuccess("Success!")
                    
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
                        
                        PopupViewController.standCreated = true
                        self.view.removeFromSuperview()
                        
                    }
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
