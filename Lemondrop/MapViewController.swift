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

class MapViewController: UIViewController, UISearchBarDelegate{
    
    
    var workingAStand = false
    var currentUsersStand: LemonadeStand?
    
    static var lemonadeStands = [LemonadeStand]()
    static var users = [User]()
    static var usernameUserMap = [String: User]()
    static var markerUserMap = [GMSMarker: User]()
    static let googleMapsApiKey = ApiKeys.googleMapsApiKey
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var tableView: UITableView!
    
    var filteredStands = [LemonadeStand]()
    
    var searchBar: UISearchBar!
    
    static var currentUser: User!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureMapbackground()
        
        configureTextField()
        
        reload()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    static func loadUsers(onSuccess: @escaping() -> Void, onFailure: @escaping() -> Void){
        
        ProgressHUD.show("Loading Stands...")
        users = []
        let ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { (snap) in
            print("User COUNT \(users.count)")
            MapViewController.users = []
            
            if let usersSnap = snap.value as? [String: NSDictionary]{
                
                for(_, user) in usersSnap {
                    
                    
                    let newUser = User(dictionary: user)
                    MapViewController.users.append(newUser)
                   print("ADDING USER")
                    MapViewController.usernameUserMap[newUser.fullname!] = newUser
                    //check that a current user is initiated
                    if newUser.uid == Auth.auth().currentUser?.uid{
                        MapViewController.currentUser = newUser
                    }
                }
                
                if MapViewController.currentUser == nil{
                    print("Must be a current user")
                    onFailure()
                    
                }
                
                onSuccess()
            } else {
                onFailure()
            }
        }
    }
    func reload(){
        print("RELOADING")
        if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Not connected to internet")
            self.configureFloatingButton()
        } else {
            
            MapViewController.loadUsers(onSuccess: {
                MapViewController.loadLemonadeStands(view: self) {
                    self.setMarkers()
                    self.configureFloatingButton()
                    
                }
            }) {
                
                AuthService.logout(sender: self)
                
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
        mapView.delegate = self
        //enable geocoding https://www.raywenderlich.com/197-google-maps-ios-sdk-tutorial-getting-started
        
        
    }
    
    func transitionMapToStand(stand: LemonadeStand?){
        if let lemonadeStand = stand{
            self.mapView.camera = GMSCameraPosition(latitude: lemonadeStand.latitude, longitude: lemonadeStand.longitude, zoom: self.zoomLevel)
        }
    }
    
    
    //floating right button
    //floaty library used
    func configureFloatingButton(){
        let floaty = Floaty()
        floaty.items = []
        floaty.buttonColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        floaty.plusColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        if !workingAStand{
            
            floaty.addItem("Establish Lemonade Stand", icon: UIImage(named: "Lemon")!) { (item) in
                self.presentEstablishStandView()
            }
        } else {
            floaty.addItem("Locate your Stand", icon: UIImage(named: "Lemon")!) { (item) in
                
                self.transitionMapToStand(stand: self.currentUsersStand)
                
            }
        }
        
        floaty.addItem("View List of All Users", icon: UIImage(named: "listview")) { (item) in
            self.presentListView()
        }
        
        floaty.addItem("Profile", icon: UIImage(named: "profile")!) { (item) in
            
            
            if let user = MapViewController.currentUser{
                self.presentProfileView(user: user)

            } else {
                ProgressHUD.showError("No current user: check internet connection and try refreshing...")
            }
        }
        floaty.addItem("Refresh", icon: UIImage(named: "refresh")!) { (item) in
            
            
            self.reload()
        }
        
        self.view.addSubview(floaty)
        
        
    }
    
    //floating textfield at the top of the screen
    func configureTextField(){
        
        searchBar = UISearchBar(frame: CGRect(x: 16, y: 42, width: view.bounds.width - 32, height: 42))
        
        searchBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchBar.layer.borderWidth = 8
        searchBar.layer.borderColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.placeholder = "Search for a Lemonade Stand"
        self.view.addSubview(searchBar)
        
    }
    
    func presentListView(){
        let listVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lemonadeStandListView")
        navigationController?.pushViewController(listVC, animated: true)
        
        
        
    }
    func presentProfileView(user: User){
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        profileVC.setUser(user: user)
        //present navigation bar when going to profile view cotnroller
        
        navigationController?.pushViewController(profileVC, animated: true)
        
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
        if let _ = tableView {
            tableView.removeFromSuperview()
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        tableView.removeFromSuperview()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView = UITableView(frame: CGRect(x: searchBar.frame.minX, y: searchBar.frame.maxY, width: searchBar.frame.width, height: 3*searchBar.frame.height), style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        
        tableView.addBorderLeft(size: 8.0, color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
        tableView.addBorderBottom(size: 8.0, color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
        tableView.addBorderRight(size: 8.0, color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
    }
    
    func updateSearchResults(for searchBar: UISearchBar) {
        filterContent(searchText: searchBar.text!)
        
    }
    
    //search ends
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    
    func filterContent(searchText: String){
        
        
        self.filteredStands = MapViewController.lemonadeStands.filter{ stand in
            
            let string = ("\(stand.standName)")
            
            return(string.lowercased().contains(searchText.lowercased()))
            
        }
        
        tableView.reloadData()
        
        
    }
    
    
    
    //search bar text changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchBar)
        
        if filteredStands.count < 1 {
            tableView.removeFromSuperview()
        } else {
            self.view.addSubview(tableView)
        }
    }
}


extension MapViewController: GMSMapViewDelegate{
    
    
    //loads all lemonade stands, checks if the currrent user is working a stand or not
    static func loadLemonadeStands(view: MapViewController, onSuccess: @escaping() -> Void){
        
        lemonadeStands = []
        //remove all markers from mapview
        view.mapView.clear()
        view.workingAStand = false
        view.currentUsersStand = nil
        
        Database.database().reference().child("activeLemonadeStands").observeSingleEvent(of: .value) { (snapshot) in
            print("LEMONADE STAND COUNT \(lemonadeStands.count)")
            if let snap = snapshot.value as? NSDictionary{
                
                for (_, stand) in snap {
                    
                    if let dict = stand as? NSDictionary {
                        let lemonadeStand = LemonadeStand(dictionary: dict)
                        if lemonadeStand.endTime > Date().timeIntervalSince1970{
                            
                            
                            //check if this stand was created by the current user
                            if lemonadeStand.userId == (Auth.auth().currentUser?.uid)! {
                                view.workingAStand = true
                                view.currentUsersStand = lemonadeStand
                            }
                            
                            MapViewController.lemonadeStands.append(lemonadeStand)
                            //thjis will bring up an issue with different time zones
                            
                            
                        }
                        
                    }
                }
                
                onSuccess()
                ProgressHUD.showSuccess("Loaded \(MapViewController.lemonadeStands.count) stand(s)")
            } else {
                ProgressHUD.showSuccess("No stands to load..")
                view.configureFloatingButton()
                
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
        
        marker.map = mapView
        marker.title = "Stand Name: \(stand.standName!) | Created By: \(stand.creatorName!)"
        print("appended")
        if stand.endTime < Date().timeIntervalSince1970{
            //closed
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        } else {
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1))
        }
        
        MapViewController.markerUserMap[marker] = MapViewController.usernameUserMap[stand.creatorName]
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        print("CLicked")
        self.presentProfileView(user: MapViewController.markerUserMap[marker]!)
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        mapView.addSubview(view)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
        
        lbl1.text = String((marker.title?.split(separator: "|")[0])!)
        view.addSubview(lbl1)
        
        
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = String((marker.title?.split(separator: "|")[1])!)
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl2)
        
        let profileButton = UIButton(frame: CGRect.init(x: view.frame.width - 64, y: lbl2.frame.origin.y + lbl2.frame.size.height + 24, width: view.frame.size.width - 16, height: 24))
        
        let horizontalCenter: CGFloat = view.bounds.size.width / 2.0
        profileButton.center = CGPoint(x: horizontalCenter, y: lbl2.frame.origin.y + lbl2.frame.size.height + 24)//horizontalCenter
        
        profileButton.setTitle("Click to View Profile", for: .normal)
        profileButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        profileButton.layer.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        profileButton.layer.cornerRadius = 6
        view.addSubview(profileButton)
        
        
        return view
    }
    
    static func reloadCurrentUser(onSuccess: @escaping() -> Void){
        let ref = Database.database().reference()
        ref.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snap) in
            if let userSnap = snap.value as? NSDictionary{
                
                let newUser = User(dictionary: userSnap)
                MapViewController.currentUser = newUser
                onSuccess()
            }
        }
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            print("locaation changed")
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
    
    
}

extension MapViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.text! != ""{
            return filteredStands.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = filteredStands[indexPath.row].standName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transitionMapToStand(stand: filteredStands[indexPath.row])
        
    }
    
    
    
}
extension UIView {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    
}


