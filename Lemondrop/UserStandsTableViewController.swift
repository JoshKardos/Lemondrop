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
class UserStandsTableViewController: UITableViewController{
    var delegate: MapViewController?
    var userStands = [Stand]()
    static var standCreated = false

    override func viewDidLoad() {
        UserStandsTableViewController.standCreated = false
        self.navigationController?.isNavigationBarHidden = false
        self.filterUserStands()
        if userStands.count == 0{
            addNoStandsLabel()
        } else {
            super.viewDidLoad()
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserStandsTableViewController.standCreated{
            view.removeFromSuperview()
            self.delegate?.reload()
        }
        
    }
    
    func filterUserStands(){
        for stand in MapViewController.lemonadeStands{
            if stand.userId == (Auth.auth().currentUser?.uid)!{
                userStands.append(stand)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StandCell
        cell.standNameLabel.triggerScrollStart()
        return
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandCell", for: indexPath) as! StandCell
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
        label.text = "You haven't established any stands.."
        label.textColor = UIColor.black
        label.textAlignment = .center
        self.view.addSubview(label)
    }
}
class ClickableUserStandsTableViewController: UserStandsTableViewController{
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Are you sure?", message: "Confirm you want to reopen '\(userStands[indexPath.row].standName!)'?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
            let popoverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "setEndTime") as! SetEndTimePopupViewController
            popoverVC.stand = self.userStands[indexPath.row]
            self.addChild(popoverVC)
            popoverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(popoverVC.view)
            popoverVC.didMove(toParent: self)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
        }))
        self.present(alert, animated:  true, completion: nil)
    }
}

