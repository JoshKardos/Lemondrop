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
    var timestamps = [String]()
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        usersMessaged.removeAll()
        loadUserMessages() 
    }
    
    //rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesDictionary.count
        
    }
    //text to put in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMessageCell", for: indexPath) as! UserCell
        
        cell.configureCell(message: messages[indexPath.row])
        
        return cell
        
    }
    
    //when row is sleected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        MessagesViewController.showChatController(otherUser: MapViewController.uidUserMap[chatPartnerId]!, view: self)

    }
    
    
    static func showChatController(otherUser: User, view: UIViewController){
        
        let chatLogController =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        
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
        ref.observe( .childAdded) { (snapshot) in
            print("SNAP \(snapshot.value)")
            //reference to message by using message key
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            //observe message reference
            messageRef.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any]{
                    
                    let message = Message(dictionary: dictionary as [String : Any] as [String : AnyObject])
                    print("ToID")
                    //should always work
                    if let toId = message.chatPartnerId()  {
                        
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return (m1.timestamp!.intValue > m2.timestamp!.intValue)
                        })
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
