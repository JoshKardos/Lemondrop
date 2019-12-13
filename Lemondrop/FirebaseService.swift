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
    
    static let storageRef = "gs://lemondrop-1558064397092.appspot.com"
    // static let photoMenus = "photoMenus"
    
    // head children
    static let standMenus = "stand-menus"
    static let stands = "stands"
    static let fullnames = "fullnames"
    static let messages = "messages"
    static let userMessages = "user-messages"
    static let userPlayerIds = "user-playerIds"
    static let userRated = "user-rated"
    static let userRatings = "user-ratings"
    static let users = "users"
    static let businesses = "businesses"
    static let userBusiness = "user-business"
    static let businessNames = "businessNames"
    static let businessStands = "business-stands"
    
    // users children
    
    static let age = "age"
    static let avatar = "avatar"
    static let email = "email"
    static let fullname = "fullname"
    static let uid = "uid"
    static let unlockedHats = "unlockedHats"
    static let unlockedPants = "unlockedPants"
    static let unlockedShirts = "unlockedShirts"
    static let hasBusinessProfile = "hasBusinessProfile"

    // user-ratings children
    
    static let raterId = "raterId"
    static let ratingId = "ratingId"
    static let score = "score"
    
    // messages children
    static let messageId = "messasgeId"
    static let senderID = "senderID"
    static let text = "text"
    static let timestamp = "timestamp"
    static let toId = "toId"
    
    // stands children
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
    
    //businesses children
    static let name = "name"
    static let businessId = "businessId"

    // standMenus children
    static let photoMenu = "photoMenu"
    static let listMenu = "listMenu"
    
}
