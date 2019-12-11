//
//  StandCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/14/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Floaty
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import MarqueeLabel
class StandCell: UITableViewCell{
    
    @IBOutlet weak var standNameLabel: MarqueeLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var businessHoursLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let dateFormatter = DateFormatter()
    
    
    func configureCell(stand: Stand){
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        standNameLabel.text = "Stand Name: \(stand.standName!)"
        
        
        let date = NSDate(timeIntervalSince1970: stand.endTime)
        dateLabel.text = "Date: \(dateFormatter.string(from: date as Date))"
        
        dateFormatter.dateFormat = "h:mm a"
        let startTimeString = dateFormatter.string(from: NSDate(timeIntervalSince1970: stand.startTime) as Date)
        let endTimeString = dateFormatter.string(from: date as Date)
        print(stand.standId)
//        print(stand.pricePerGlass)
//        priceLabel.text = "Glass Price: $\(stand.pricePerGlass!)"
        businessHoursLabel.text = "Hours: \(startTimeString)-\(endTimeString)"
        cityLabel.text = stand.city
        
        
        let location = CLLocation(latitude: CLLocationDegrees(floatLiteral: stand.latitude), longitude: CLLocationDegrees(floatLiteral: stand.longitude))
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = UIImage(named: "mapViewLemon")
        marker.map = mapView
        mapView.camera = GMSCameraPosition(latitude: stand.latitude, longitude: stand.longitude, zoom: Float(15.0))
        
        
        mapView.isUserInteractionEnabled = false
        
    }
    
}
