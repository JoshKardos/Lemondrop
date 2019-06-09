//
//  Message.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/5/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import FirebaseAuth
class Message: NSObject{
    var senderId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    override init(){
        super.init()
    }
    init(dictionary: [String: AnyObject]){
        senderId = (dictionary["senderID"] as! String)
        text = dictionary["text"] as! String
        timestamp = (dictionary["timestamp"] as! NSNumber)
        toId = (dictionary["toId"] as! String)
    }
    func chatPartnerId() -> String?{
        
        let uid = Auth.auth().currentUser!.uid
        
        if senderId == uid{
            return toId
        }else{
            return senderId
        }
    }
}
