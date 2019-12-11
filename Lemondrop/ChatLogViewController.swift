//
//  ChatLogViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/4/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//


import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import SwipeCellKit
import OneSignal
class ChatLogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout ,UICollectionViewDelegate , UITextFieldDelegate, SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //if senderId != currentId
            // return []
        if messages[indexPath.row].senderId != Auth.auth().currentUser?.uid{
            guard orientation == .right else { return nil }
        } else {
            guard orientation == .left else { return nil }
        }
        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if self.messages[indexPath.row].messageId == nil {
                ProgressHUD.showError("Did Not delete")
                return
            }
            Database.database().reference().child(FirebaseNodes.userMessages).child((Auth.auth().currentUser?.uid)!).child(self.messages[indexPath.row].messageId!).removeValue()
            
            self.messages.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    var origin: CGFloat?
    var messages = [Message]()
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
//    let toolbar = UIToolbar()
//    let bottomContainerView = UIView() // holds text field and send button
    var otherUser: User?{
        didSet {
            navigationItem.title = otherUser?.fullname
            
            observeMessages()
        }
    }
    let cellId = "cellId"
    
    
    
    override func viewDidLoad() {
        
        //        ProgressHUD.show("Loading...")
        super.viewDidLoad()
        
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        setupBottomComponents()
        

        collectionView!.register(DirectMessageBubble.self, forCellWithReuseIdentifier: cellId)
        
        collectionView!.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView!.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        
        collectionView!.alwaysBounceVertical = true
        collectionView!.delegate = self
        collectionView!.dataSource = self
//        collectionView!.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor)
        
        self.view.addSubview(collectionView!)
        
        collectionView!.backgroundColor = UIColor.white
        
        
    }
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child(FirebaseNodes.userMessages).child(uid)
        
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = Database.database().reference().child(FirebaseNodes.messages).child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
                
                if message.chatPartnerId() == self.otherUser?.uid{
                    self.messages.append(message)
                    
                    
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadCollection), userInfo: nil, repeats: false)
            })
        }, withCancel: nil)
    }
    
    var timer: Timer?
    @objc func handleReloadCollection(){
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
            
            let lastItemIndex = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DirectMessageBubble
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        cell.delegate = self
        
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32
        
        return cell
    }
    private func setUpCell(cell: DirectMessageBubble, message: Message){
        
        if message.senderId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        
        
        
    }
    private func estimatedFrameForText(text: String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat?
        
        if let text = messages[indexPath.item].text{
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height!)
    }
    func setupBottomComponents(){
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    @objc func doneClicked(){
        view.endEditing(true)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            
            
            self.origin = self.view.frame.origin.y
            self.view.frame.origin.y =  self.view.frame.origin.y - keyboardHeight
            
            
            
        }
        
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if let origin = origin {
            
            self.view.frame.origin.y = origin
        }
    }
    
    
    @objc func sendPressed(){
        
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.endEditing(true)
            ProgressHUD.showError("Empty message")
            return
        }
        
        if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("No internet connection")
            return
        }
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child(FirebaseNodes.messages)
        let childRef = ref.childByAutoId()
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let toId = otherUser!.uid
        
        let values = ["text": textField.text!, "senderID": uid, "toId": toId, "timestamp": timestamp, "messageId": childRef.key!] as [String : Any]
        
        childRef.updateChildValues(values, withCompletionBlock: { (error, snapshot) in
            if error != nil{
                print(error)
                return
            }
            self.textField.text = nil
            let userMessagesRef = Database.database().reference().child(FirebaseNodes.userMessages).child(uid)
            let messageId = childRef.key
            
            userMessagesRef.updateChildValues([messageId!: 1])
            
            
            let recipientUserMessagesRef = Database.database().reference().child(FirebaseNodes.userMessages).child(toId!)
            recipientUserMessagesRef.updateChildValues([messageId!: 1])
            
            self.notifyUser()
            
//            SNSService.shared.publish(description: "Message from: ", from: MapViewController.currentUser!, to: self.otherUser!)
        })
        view.endEditing(true)
    }
    
    func notifyUser(){
        
        Database.database().reference().child(FirebaseNodes.userPlayerIds).child((self.otherUser?.uid)!).observe( .value) { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary{
                var usersEndpoints:[String] = []
                
                for (key, _) in dictionary{
                    usersEndpoints.append(key as! String)
                }
                
                OneSignal.postNotification(["contents": ["en":"\(MapViewController.currentUser.fullname!) sent you a message"],
                                            "include_player_ids": usersEndpoints])
            }
            
        }
//        OneSignal.postNotification(["contents": ["en":"\(MapViewController.currentUser.fullname) sent you a message"],
//                                    "included_segments": [self.otherUser?.uid!]])
    }
    
}



