//
//  LemonadeStand.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import CoreLocation
class LemonadeStand{
    var latitude: Double!
    var longitude: Double!
    var standName: String!
    var startTime: Double!
    var endTime: Double!
    var pricePerGlass: Double!
    var userId: String!
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
        guard let userId = dictionary["userId"] as? String else {
            print("bad user id")
            return
        }
        
        let price = Double(pricePerGlass)
        
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.standName = standName
        self.startTime = startTime
        self.endTime = endTime
        self.pricePerGlass = price
        
        
    }
}
