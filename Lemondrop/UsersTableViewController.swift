//
//  StandTableViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/30/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != nil && searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            return filteredUsers.count
        }
        
        return MapViewController.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserAndStandCell
        
        if searchBar.text != nil && searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            for stand in MapViewController.lemonadeStands{
                if stand.creatorName == filteredUsers[indexPath.row].fullname{
                    
                    cell.configureCell(username: filteredUsers[indexPath.row].fullname!, standsLabel: "Stand: \(stand.standName!)" )
                    return cell
                }
            }
            cell.configureCell(username: filteredUsers[indexPath.row].fullname!, standsLabel: "Stand: No stand")
            return cell
        }
        
        for stand in MapViewController.lemonadeStands{
            if stand.creatorName == MapViewController.users[indexPath.row].fullname{
                
                cell.configureCell(username: MapViewController.users[indexPath.row].fullname!, standsLabel: "Stand: \(stand.standName!)" )
                return cell
            }
        }
        cell.configureCell(username: MapViewController.users[indexPath.row].fullname!, standsLabel: "Stand: No stand")
        return cell
    }
    
    func presentProfileView(user: User){
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        profileVC.setUser(user: user)
        //present navigation bar when going to profile view cotnroller
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.text != nil && searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            presentProfileView(user: self.filteredUsers[indexPath.row])
        } else {
            presentProfileView(user: MapViewController.users[indexPath.row])
        }
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
}

extension UsersTableViewController: UISearchBarDelegate{
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
    
    func updateSearchResults(for searchBar: UISearchBar) {
        filterContent(searchText: searchBar.text!)
        
    }
    
    //search ends
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    
    func filterContent(searchText: String){
        
        
        self.filteredUsers = MapViewController.users.filter{ user in
            
            let string = ("\(user.fullname)")
            
            return(string.lowercased().contains(searchText.lowercased()))
            
        }
        
        tableView.reloadData()
        
        
    }
    
    
    
    //search bar text changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchBar)
    }
}
