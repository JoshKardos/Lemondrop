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

       
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if MapViewController.users[indexPath.row].uid != MapViewController.currentUser!.uid {
            MessagesViewController.showChatController(otherUser: MapViewController.users[indexPath.row], view: self)

        } else {
            ProgressHUD.showError("Can't Message Yourself")
        }
    }
}
