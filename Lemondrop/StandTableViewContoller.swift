//
//  UserStandsTableViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/14/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import ProgressHUD
class StandTableViewController: UITableViewController{
    
    var delegate: MapViewController?
    var userStands = [Stand]()
    var selectedStand: Stand?
    static var standCreated = false
    
    override func viewDidLoad() {
        StandTableViewController.standCreated = false
        self.navigationController?.isNavigationBarHidden = false
        self.fillUserStands()
        if userStands.count == 0 {
            addNoStandsLabel()
        } else {
            super.viewDidLoad()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if StandTableViewController.standCreated {
            view.removeFromSuperview()
        }
    }
    
    // fill stand with current user stands
    func fillUserStands(){
        userStands = []
        for stand in MapViewController.currentUserStands {
            userStands.append(stand)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StandStatusCell
        cell.standNameLabel.triggerScrollStart()
        return
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandCell", for: indexPath) as! StandStatusCell
        cell.configureCell(stand: userStands[indexPath.row])
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userStands.count
    }
    
    func addNoStandsLabel(){
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 32))
        label.text = "There are no stands open..."
        label.textColor = UIColor.black
        label.textAlignment = .center
        self.view.addSubview(label)
    }
}

class StandClosedTableViewController: StandTableViewController {
    
    override func fillUserStands () {
        print("FILL USER STANDS")
        userStands = []
        for stand in MapViewController.currentUserStands {
            if stand.isOpen() {
                userStands.append(stand)
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Are you sure you want to close?", message: "Confirm close '\(userStands[indexPath.row].standName!)'?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
            self.closeStand(stand: self.userStands[indexPath.row])
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
        }))
        self.present(alert, animated:  true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandCell", for: indexPath) as! StandClosedCell
        cell.configureCell(stand: userStands[indexPath.row])
        return cell
    }
    
    func closeStand (stand: Stand){
        
        if stand.endTime == nil || stand.endTime! <= Date().timeIntervalSince1970 {
            ProgressHUD.showError("Stand is already closed..")
            return
        }
        // close stand
        Database.database().reference().child(FirebaseNodes.stands).child(stand.standId).child(FirebaseNodes.endTime).setValue(Date().timeIntervalSince1970) { (error, ref) in

            // reload and reload table view
            MapViewController.reloadCurrentUserStand(standId: stand.standId, onSuccess: {
                self.fillUserStands()
                self.tableView.reloadData()
                if self.userStands.count == 0 {
                    self.addNoStandsLabel()
                }

            })
        }
    }
}

class StandStatusTableViewController: StandTableViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocationSelector"{
            guard let stand = self.selectedStand else {
                return
            }
            let destination = segue.destination as! LocationSelectorViewController
            destination.stand = stand
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedStand = userStands[indexPath.row]
        
        let alert = UIAlertController(title: "Are you sure?", message: "Confirm you want to reopen '\(userStands[indexPath.row].standName!)'?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
            self.performSegue(withIdentifier: "ShowLocationSelector", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
        }))
        self.present(alert, animated:  true, completion: nil)
    }
}

