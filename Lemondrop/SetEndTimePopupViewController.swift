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
    var stand: Stand!
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        container.layer.cornerRadius = 12
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        endTimePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func confirmButtonPressed(_ sender: Any) {
        openStand(stand: stand!, endAt: endTimePicker.date)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            self.view.removeFromSuperview()
        }
    }
    
    func openStand(stand: Stand, endAt withDate: Date){
        
        guard let _ = stand.latitude, let _ = stand.longitude else {
            ProgressHUD.showError("Go back and set the location again")
            return
        }
        let newRef = Database.database().reference().child(FirebaseNodes.stands).child(stand.standId!)
        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            newRef.updateChildValues(["latitude": stand.latitude!, "longitude": stand.longitude!, "startTime": Date().timeIntervalSince1970 , "endTime": withDate.timeIntervalSince1970]){ (error, ref) in
                if error != nil{
                    ProgressHUD.showError("Failure opening stand...")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    return
                } else {
                    ProgressHUD.showSuccess("Success, \(stand.standName!) is now opened!")
                    print("setting to true")
                    UserStandsTableViewController.standCreated = true
                    self.view.removeFromSuperview()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
            }
            
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
