//
//  LemonadeStand.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import CoreLocation
class Stand{
    var latitude: Double!
    var longitude: Double!
    var standName: String!
    var startTime: Double!
    var endTime: Double!
    var pricePerGlass: Double!
    var userId: String!
    var creatorName: String!
    var city: String!
    var standId: String!
    init(dictionary: NSDictionary){
        
        guard let latitude = dictionary["latitude"] as? Double else {
            print("bad latitude")
            return
        }
        guard let longitude = dictionary["longitude"] as? Double else {
            print("bad longitude")
            return
        }
        guard let standName = dictionary["standName"] as? String else {
            print("bad standname")
            return
        }
        guard let endTime = dictionary["endTime"] as? Double else {
            print("Bad endtime")
            return
        }
        guard let startTime = dictionary["startTime"] as? Double else {
            print("bad start time")
            return
        }
        
        guard let pricePerGlass = dictionary["pricePerGlass"] as? String else {
            print("bad priceperglass")
            return
        }
        guard let userId = dictionary["userID"] as? String else {
            print("bad user id")
            return
        }
        guard let username = dictionary["creatorFullname"] as? String else {
            print("bad username")
            return
        }
        guard let city = dictionary["city"] as? String else {
            print("bad city")
            return
        }
        guard let id = dictionary["standId"] as? String else {
            print("bad standId")
            return
        }
        let price = Double(pricePerGlass)
        print(price)
        self.creatorName = username
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.standName = standName
        self.startTime = startTime
        self.endTime = endTime
        self.pricePerGlass = price
        self.city = city
        self.standId = id
    }
    
    init(otherStand: Stand, id: String){
        self.creatorName = otherStand.creatorName
        self.userId = otherStand.userId
        self.latitude = otherStand.latitude
        self.longitude = otherStand.longitude
        self.standName = otherStand.standName
        self.startTime = otherStand.startTime
        self.endTime = otherStand.endTime
        self.pricePerGlass = otherStand.pricePerGlass
        self.city = otherStand.city
        self.standId = id
    }
    
}
