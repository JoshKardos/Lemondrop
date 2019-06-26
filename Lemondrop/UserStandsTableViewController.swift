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
class UserStandsTableViewController: UITableViewController{
    
    var userStands = [LemonadeStand]()
    
    override func viewDidLoad() {
        self.filterUserStands()
        if userStands.count == 0{
            print("00000")
            addNoStandsLabel()
        } else {
            super.viewDidLoad()
            
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            self.tableView.reloadData()
        }
        
        
    }
    
    
    func filterUserStands(){
        
        for stand in MapViewController.lemonadeStands{
            
            if stand.userId == (Auth.auth().currentUser?.uid)!{
                userStands.append(stand)
            }
        }
        
        
        
        
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
