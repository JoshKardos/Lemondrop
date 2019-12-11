//
//  User.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/21/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
class User{
    
    var uid: String!
    var fullname: String!
    var email: String!
    var avatar: [String: String]!
    
    var unlockedHats = [String]()
    var unlockedShirts = [String]()
    var unlockedPants = [String]()
    var rating: Double?
//    var usersRatedIds = [String]()
    var hasBusinessProfile: Bool?
    var token = ""{
        didSet{
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    static let current = User()
    
    private init(){}
    
    init(dictionary: NSDictionary){
        
        uid = (dictionary["uid"] as! String)
        fullname = (dictionary["fullname"] as! String)
        email = (dictionary["email"] as! String)
        avatar = (dictionary["avatar"] as! [String: String])
        hasBusinessProfile=((dictionary["hasBusinessProfile"] as? NSString)?.boolValue)
        //unlocked hats
        for hatIndex in dictionary["unlockedHats"] as! [String]{
            
            unlockedHats.append(hatIndex)
        }
//        //unlocked shirts
        for shirtIndex in dictionary["unlockedShirts"] as! [String]{
            unlockedShirts.append(shirtIndex)
        }
//        //unlockedn pants
        for pantIndex in dictionary["unlockedPants"] as! [String]{
            unlockedPants.append(pantIndex)
        }
    }
    
    
    
}
