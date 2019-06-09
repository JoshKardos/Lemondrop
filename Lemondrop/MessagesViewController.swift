//
//  MessagesViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/5/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
class MessagesViewController: UITableViewController{
    
    var usersMessaged = [User]()
    var databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        
        //ProgressHUD.show("Loading...")
        super.viewDidLoad()
        usersMessaged.removeAll()
        loadUserMessages()
        
    }
    
    //rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.usersMessaged.count
        
    }
    //text to put in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMessageCell", for: indexPath) as! UserCell
        cell.configureCell(fullname: usersMessaged[indexPath.row].fullname)
        return cell
        
    }
    
    //when row is sleected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let chatPartnerId = usersMessaged[indexPath.row].uid else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            
            guard let dictionary = snapshot.value as? NSDictionary else{ return }
            
            let user = User(dictionary: dictionary)
            
            user.uid = chatPartnerId
            
            MessagesViewController.showChatController(otherUser: user, view: self)
            
        }
        
    }
    
    
    static func showChatController(otherUser: User, view: UIViewController){
        
        let chatLogController = ChatLogViewController()
        
        chatLogController.otherUser = otherUser
        
        view.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    
    func loadUserMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //ref of users messages keys
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        //iterate through messages keys
        ref.observe(.childAdded) { (snapshot) in
            
            //reference to message by using message key
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            //observe message reference
            messageRef.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any]{
                    
                    let message = Message(dictionary: dictionary as [String : Any] as [String : AnyObject])
                    
                    //should always work
                    if let toId = message.chatPartnerId()  {
                        self.usersMessaged.append(MapViewController.uidUserMap[toId]!)
//                        self.messagesDictionary[toId] = message
//                        self.messages = Array(self.messagesDictionary.values)
//                        self.messages.sort(by: { (m1, m2) -> Bool in
//                            return (m1.timestamp!.intValue > m2.timestamp!.intValue)
//                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                    
                }
            })
        }
    }
    
    var timer: Timer?
    @objc func handleReloadTable(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func addThreadPressed(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let view = storyboard.instantiateViewController(withIdentifier: "addMessageThreadView")
        
        navigationController?.pushViewController(view, animated: true)
        
        
        
        
    }
}
