//
//  MapViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/16/19.
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

class MapViewController: UIViewController, UITextFieldDelegate{
    let floaty = Floaty()
    var workingAStand = false
    static var lemonadeStands = [LemonadeStand]()
    static let googleMapsApiKey = ApiKeys.googleMapsApiKey
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?{
        didSet{
            //            currentLocationMarker.position = currentLocation!.coordinate
            //            currentLocationMarker.map = mapView
        }
    }
    //    var currentLocationMarker = GMSMarker()
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureMapbackground()
        
        configureTextField()
        
        if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Not connected to internet")
        } else {
            checkIfWorkingAStand() {
                self.configureFloatingButton()
            }
            
            
            MapViewController.loadLemonadeStands(mapView: mapView) {
                self.setMarkers()
            }
        }
        
    }
    
    //adds map to view
    //does not add buttons
    func configureMapbackground(){
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: 38.5116,
                                              longitude: 121.4944,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        mapView.isMyLocationEnabled = true
        
        //enable geocoding https://www.raywenderlich.com/197-google-maps-ios-sdk-tutorial-getting-started
        
        
    }
    
    func checkIfWorkingAStand(onSuccess: @escaping() -> Void){
        
        Database.database().reference().child("activeLemonadeStands").observe(.value) { (snapshot) in
            
            if let snap = snapshot.value as? NSDictionary{
                
                for (_, stand) in snap {
                    
                    if let dict = stand as? NSDictionary {
                        
                        let lemonadeStand = LemonadeStand(dictionary: dict)
                        
                        if lemonadeStand.userId == (Auth.auth().currentUser?.uid)! {
                            self.workingAStand = true
                            break
                        }
                        
                    }
                    
                }
                
                onSuccess()
            }
        }
        
    }
    
    
    //floating right button
    //floaty library used
    func configureFloatingButton(){
        
        floaty.items = []
        floaty.buttonColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        floaty.plusColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        if !workingAStand{
            
            floaty.addItem("Establish Lemonade Stand", icon: UIImage(named: "Lemon")!) { (item) in
                self.presentEstablishStandView()
            }
        } else {
            floaty.addItem("Locate your Lemonade Stand", icon: UIImage(named: "Lemon")!) { (item) in
                //                self.presentEstablishStandView()
                
                
                
            }
        }
        
        floaty.addItem("Refresh", icon: UIImage(named: "refresh")!) { (item) in
            
            
            MapViewController.loadLemonadeStands(mapView: self.mapView, onSuccess: {
                self.setMarkers()
            })
        }
        
        self.view.addSubview(floaty)
        
        
    }
    
    //floating textfield at the top of the screen
    func configureTextField(){
        let textField = UITextField(frame: CGRect(x: 16, y: 42, width: view.bounds.width - 32, height: 42))
        
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        
        textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.layer.borderWidth = 3
        textField.layer.borderColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        textField.layer.cornerRadius = 8
        textField.returnKeyType = .done
        textField.delegate = self
        textField.placeholder = "Search by the stand owner's full name"
        self.view.addSubview(textField)
        
    }
    
    func presentEstablishStandView(){
        let popoverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "establishStand") as! PopupViewController
        popoverVC.delegate = self
        self.addChild(popoverVC)
        popoverVC.view.frame = self.view.frame
        self.view.addSubview(popoverVC.view)
        popoverVC.didMove(toParent: self)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        view.endEditing(true)
        return true
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        
        
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    static func loadLemonadeStands(mapView: GMSMapView, onSuccess: @escaping() -> Void){
        
        
        
        lemonadeStands = []
        //remove all markers from mapview
        mapView.clear()
        
        
        ProgressHUD.show("Loading Stands...")
        Database.database().reference().child("activeLemonadeStands").observe(.value) { (snapshot) in
            print(lemonadeStands.count)
            if let snap = snapshot.value as? NSDictionary{
                
                for (_, stand) in snap {
                    if let dict = stand as? NSDictionary {
                        let lemonadeStand = LemonadeStand(dictionary: dict)
                        if lemonadeStand.endTime < Date().timeIntervalSince1970{
                            
                            Database.database().reference().child("activeLemonadeStands").child(dict["standId"] as! String).removeValue()
                            print("deleted")
                        }
                        else {
                            MapViewController.lemonadeStands.append(lemonadeStand)
                        }
                        
                    }
                }
                
                onSuccess()
                ProgressHUD.showSuccess("Loaded \(MapViewController.lemonadeStands.count) stand(s)")
            } else {
                ProgressHUD.showSuccess("No stands to load..")
                
                
            }
        }
        
        
    }
    
    func setMarkers(){
        
        for stand in MapViewController.lemonadeStands{
            
            setMarker(stand: stand)
        }
        
        
    }
    
    func setMarker(stand: LemonadeStand){
        
        let location = CLLocation(latitude: CLLocationDegrees(floatLiteral: stand.latitude), longitude: CLLocationDegrees(floatLiteral: stand.longitude))
        let marker = GMSMarker(position: location.coordinate)
        marker.title = stand.standName
        marker.map = mapView
        if stand.endTime < Date().timeIntervalSince1970{
            //closed
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        } else {
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1))
        }
    }
}
