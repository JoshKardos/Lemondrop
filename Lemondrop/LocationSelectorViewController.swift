//
//  LocationSelectorViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 12/12/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationSelectorViewController: UIViewController {
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var stand: Stand?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapbackground()
    }
    
    @IBAction func confirmPressed(_ sender: UIBarButtonItem) {
        guard let popoverStand = stand else {
            return
        }
        let popoverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "setEndTime") as! SetEndTimePopupViewController
        let location = mapView.camera.target
        popoverStand.setLocation(location: location)
        popoverVC.stand = popoverStand
        
        self.addChild(popoverVC)
        popoverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(popoverVC.view)
        popoverVC.didMove(toParent: self)
    }
    
    //adds map to view
    //does not add buttons
    func configureMapbackground(){
        let camera = GMSCameraPosition.camera(withLatitude: MapViewController.currentLocation!.coordinate.latitude, longitude: MapViewController.currentLocation!.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = false
        mapView.camera = camera
        let markerView = UIView(frame: CGRect(x: mapView.frame.width/2 - 50, y: mapView.frame.height/2 - 50, width: 26, height: 26))
        markerView.layer.cornerRadius = 13
        markerView.center = mapView.center
        markerView.backgroundColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
        markerView.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        markerView.layer.borderWidth = 4
        mapView.addSubview(markerView)
        
        let label = UILabel(frame: CGRect(x: mapView.frame.width/2 - 57.5, y: mapView.frame.height/2 + 16, width: 115, height: 16))
        label.text = "Stand Location"
        mapView.addSubview(label)
        label.topAnchor.constraint(equalTo: markerView.bottomAnchor, constant: 6).isActive = true
    }
}
