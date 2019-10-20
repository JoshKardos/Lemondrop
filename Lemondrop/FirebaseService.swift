//
//  FirebaseService.swift
//  Lemondrop
//
//  Created by Josh Kardos on 10/19/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation

import Foundation
import CoreLocation
class FirebaseNodes {
    
    // head children
    static let activeStands = "activeLemonadeStands" // done
    static let fullnames = "fullnames"
    static let messages = "messages"
    static let userMessages = "user-messages"
    static let userPlayerIds = "user-playerIds"
    static let userRated = "user-rated"
    static let userRatings = "user-ratings"
    static let users = "users"
    
    // users children
    
    static let age = "age"
    static let avatar = "avatar"
    static let email = "email"
    static let fullname = "fullname"
    static let uid = "uid"
    static let unlockedHats = "unlockedHats"
    static let unlockedPants = "unlockedPants"
    static let unlockedShirts = "unlockedShirts"
    
    // user-ratings children
    
    static let raterId = "raterId"
    static let ratingId = "ratingId"
    static let score = "score"
    
    // massages children
    
    static let messageId = "messasgeId"
    static let senderID = "senderID"
    static let text = "text"
    static let timestamp = "timestamp"
    static let toId = "todId"
    
    // activeLemonadeStands children
    static let city = "city"
    static let creatorFullname = "creatorFullname"
    static let endTime = "endTime"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let pricePerFlass = "pricePerGlass"
    static let standId = "standId"
    static let standName = "standName"
    static let startTime = "startTime"
    static let userID = "userID"
    
}
