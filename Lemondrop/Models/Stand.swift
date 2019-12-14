//
//  Lemondrop
//
//  Created by Josh Kardos on 5/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import CoreLocation
class Stand{
    var latitude: Double?
    var longitude: Double?
    var standName: String!
    var startTime: Double?
    var endTime: Double?
    var userId: String!
    var creatorName: String!
    var standId: String!
    var type: String!
    
    func isOpen() -> Bool{
        return endTime != nil && endTime! > Date().timeIntervalSince1970 && startTime != nil  && startTime! <= Date().timeIntervalSince1970
    }
    
    init(dictionary: NSDictionary){
        
        guard let standName = dictionary["standName"] as? String else {
            print("bad standname")
            return
        }
        
        guard let userId = dictionary["uid"] as? String else {
            print("bad user id")
            return
        }
        
        guard let id = dictionary["standId"] as? String else {
            print("bad standId")
            return
        }
        
        guard let type = dictionary["type"] as? String else {
            print("bad type")
            return
        }
        
        self.userId = userId
        self.standId = id
        self.type = type
        self.standName = standName
        
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.startTime = dictionary["startTime"] as? Double
        self.endTime = dictionary["endTime"] as? Double
    }
    
    func setCreatorName (name: String) {
        self.creatorName = name
    }
    
    func setLocation (location: CLLocationCoordinate2D) {
        self.latitude = Double(location.latitude)
        self.longitude = Double(location.longitude)
    }
    
    init(otherStand: Stand, id: String){
        self.userId = otherStand.userId
        self.latitude = otherStand.latitude
        self.longitude = otherStand.longitude
        self.standName = otherStand.standName
        self.startTime = otherStand.startTime
        self.endTime = otherStand.endTime
        self.standId = id
        self.type = otherStand.type
    }
    
}
