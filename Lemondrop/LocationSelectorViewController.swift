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
import EasyTipView
class LocationSelectorViewController: UIViewController, GMSMapViewDelegate{
    var markerView: UIView!
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
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = false
        mapView.camera = camera
        mapView.delegate = self
        
        let tooltipWidth: CGFloat = 200
        let tooltipFrame = CGRect(origin: CGPoint(x: self.view.bounds.width/2 - tooltipWidth/2, y: 140.0), size: CGSize(width: tooltipWidth, height: 80))
        self.view.addSubview(Tooltip(frame: tooltipFrame, text: "Choose your stand location!"))
        
//
//        markerView = UIView(frame: CGRect(x: mapView.frame.width/2 - 50, y: mapView.frame.height/2 - 50, width: 26, height: 26))
//        markerView.layer.cornerRadius = 13
//        markerView.backgroundColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
//        markerView.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        markerView.layer.borderWidth = 4
////        mapView.addSubview(markerView)
//
//        let label = UILabel(frame: CGRect(x: mapView.frame.width/2 - 57.5, y: mapView.frame.height/2 + 16, width: 115, height: 16))
//        label.text = "Stand Location"
////        mapView.addSubview(label)
//        label.topAnchor.constraint(equalTo: markerView.bottomAnchor, constant: 6).isActive = true
    }
    
    func setMarker() {
        mapView.clear()
        let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude) //(latitude: CLLocationDegrees(floatLiteral: stand.latitude!), longitude: CLLocationDegrees(floatLiteral: stand.longitude!))
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1))
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("map did change")
        setMarker()
    }
}


class Tooltip: UIView {
    
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        configureView(text: text)
    }
    
    func configureView (text: String) {
        let label = UILabel(frame: CGRect(origin: self.bounds.origin, size: self.bounds.size))
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 100
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        let closeButton = UIButton(frame: CGRect(x: self.frame.width - 18, y: 8, width: 12, height: 6))
        closeButton.setTitle("X", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: (closeButton.titleLabel?.font.pointSize)!)
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        layer.opacity = 0.7
        layer.cornerRadius = 4
        self.addSubview(label)
        self.addSubview(closeButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
