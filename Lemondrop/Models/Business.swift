//
//  Message.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/5/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import FirebaseAuth
class Business {
    var businessId: String?
    var name: String?
    var userId: String?

    init(dictionary: [String: AnyObject]){
        businessId = dictionary[FirebaseNodes.userID] as! String
        name = dictionary[FirebaseNodes.name] as! String
        userId = dictionary[FirebaseNodes.userID] as! String
    }
}
