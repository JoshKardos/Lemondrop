//
//  AddMessageThreadViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/6/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
class AddMessageThreadViewController: UsersTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find A User"
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if MapViewController.users[indexPath.row].uid != MapViewController.currentUser!.uid {
            
            if searchBar.text != nil && searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                 MessagesViewController.showChatController(otherUser: self.filteredUsers[indexPath.row], view: self)
                
            } else {
                
                MessagesViewController.showChatController(otherUser: MapViewController.users[indexPath.row], view: self)
            }
            

        } else {
            ProgressHUD.showError("Can't Message Yourself")
        }
    }
}
