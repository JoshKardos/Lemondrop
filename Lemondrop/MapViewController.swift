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
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController{
    
    let floaty = Floaty()
    var workingAStand = false
    static var lemonadeStands = [Stand]()
    static var activeStands = [Stand]()
    static var users = [User]()
    static var uidUserMap = [String: User]()
    static var markerUserMap = [GMSMarker: User]()
    static var currentUsersBusiness: Business?
    static var currentUserStands = [Stand]()
    var locationManager = CLLocationManager()
    static var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var tableView: UITableView!
    static var filteredStands = [Stand]()
    var searchBar: UISearchBar!
    var greetingLabel = UILabel()
    var distanceTimeView: UIView?
    var polyline: GMSPolyline?
    var clearButton: UIButton?
    static var currentUser: User!
    var profileSegue = "ProfileStoryboard"
    var reloadView: UIView?
    static var firstTimeLoggingIn = false
    
    override func viewDidLoad() {
        if Auth.auth().currentUser!.isEmailVerified{
            super.viewDidLoad()
            configureMapbackground()
            reload()
        } else {
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                //self.reload()
                MapViewController.firstTimeLoggingIn = true
                MapViewController.configureEmailNotVerifiedPage(viewController: self)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        if UserStandsTableViewController.standCreated {
            self.reload()
            UserStandsTableViewController.standCreated = false
        }
    }
    
    static func configureEmailNotVerifiedPage(viewController: UIViewController){
        
        let label = UILabel(frame: CGRect(x: 0, y: 16, width: viewController.view.frame.width, height: 48))
        label.numberOfLines = 2
        label.text = "Must verify your email, sign out and then sign back in when you have finished verifying"
        label.textAlignment = .center
        label.center = viewController.view.center
        viewController.view.addSubview(label)
        
        let buttonHeight: CGFloat = 48
        
        let signOutButton = UIButton(frame: CGRect(x: 0, y: viewController.view.frame.height - buttonHeight, width: viewController.view.frame.width/2, height: buttonHeight))
        viewController.view.addSubview(signOutButton)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(UIColor.white, for: .normal)
        signOutButton.layer.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        signOutButton.addTarget(viewController, action: #selector(signOut), for: .touchUpInside)
        
        let resendLinkButton = UIButton(frame: CGRect(x: viewController.view.frame.width - (viewController.view.frame.width/2), y: viewController.view.frame.height - buttonHeight, width: viewController.view.frame.width/2, height: buttonHeight))
        viewController.view.addSubview(resendLinkButton)
        resendLinkButton.setTitle("Resend Link", for: .normal)
        resendLinkButton.setTitleColor(UIColor.white, for: .normal)
        resendLinkButton.layer.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        resendLinkButton.addTarget(viewController, action: #selector(resendLink), for: .touchUpInside)
    }
    
    @objc func signOut(){
        AuthService.logout(sender: self)
    }
    
    @objc func resendLink(){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            ProgressHUD.showSuccess("Sent a new verification link")
        })
    }
    
    static func loadUsers(onSuccess: @escaping() -> Void, onFailure: @escaping() -> Void){
        
        users = []
        
        let ref = Database.database().reference()
        ref.child(FirebaseNodes.users).observeSingleEvent(of: .value) { (snap) in
            MapViewController.users = []
            if let usersSnap = snap.value as? [String: NSDictionary]{
                for(_, user) in usersSnap {
                    let newUser = User(dictionary: user)
                    MapViewController.users.append(newUser)
//                    MapViewController.usernameUserMap[newUser.fullname!] = newUser
                    MapViewController.uidUserMap[newUser.uid!] = newUser
                    //check that a current user is initiated
                    if newUser.uid == Auth.auth().currentUser?.uid{
                        MapViewController.currentUser = newUser
                        //load business here
                        MapViewController.loadBusiness(userId: newUser.uid)
                    }
                }
                if MapViewController.currentUser == nil{
                    print("There must be a current user")
                    onFailure()
                }
                onSuccess()
            } else {
                onFailure()
            }
        }
    }
    
    static func loadBusiness(userId id: String) {

        currentUsersBusiness = nil
        Database.database().reference().child(FirebaseNodes.userBusiness).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let businessId = snapshot.value as? String {
                Database.database().reference().child(FirebaseNodes.businesses).child(businessId).observe(.value, with: { (snapshot) in
                    if let businessDictionary = snapshot.value as? [String: AnyObject] {
                        MapViewController.currentUsersBusiness = Business(dictionary: businessDictionary)
                    }
                })
            }
        }, withCancel: nil)
    }
    
    static func reloadCurrentUser(){
        let ref = Database.database().reference()
        ref.child(FirebaseNodes.users).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snap) in
            
            if let user = snap.value as? NSDictionary{
                let newUser = User(dictionary: user)
                MapViewController.currentUser = newUser
            }
        }
    }
    
    static func reloadCurrentUsersBusiness(onSuccess: @escaping() -> Void) {
        print("RELOADING")
        guard let _ = currentUsersBusiness else {
            print("RELOADING BUSINESS - no current users business")
            return
        }
        let ref = Database.database().reference()
        ref.child(FirebaseNodes.businesses).child(MapViewController.currentUsersBusiness!.businessId!).observeSingleEvent(of: .value) { (snap) in
            print("IN REF")
            print(snap)
            if let business = snap.value as? [String: AnyObject]{
                print("PASSED REF")
                let newBusiness = Business(dictionary: business)
                MapViewController.currentUsersBusiness = newBusiness
                onSuccess()
            }
        }
    }
    
    func configureFloatingReloadButton(){
        //create view background
        
        let viewHeightWidth: CGFloat = 120
        let buttonHeightWidth: CGFloat = viewHeightWidth/2
        
        reloadView = UIView(frame: CGRect(x: self.view.frame.width/2 - viewHeightWidth/2, y: self.view.frame.height/2 - viewHeightWidth/2, width: viewHeightWidth, height: viewHeightWidth))
        reloadView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        reloadView?.layer.cornerRadius = 12
        
        //create label
        let labelHeight: CGFloat = 20
        
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: viewHeightWidth, height: labelHeight))
        label.text = "Click to reload..."
        label.textAlignment = .center
        label.font = label.font.withSize(15)
        
        //create button
        let button = UIButton(frame: CGRect(x: reloadView!.frame.width/2 - buttonHeightWidth/2, y: labelHeight + 25, width: buttonHeightWidth, height: buttonHeightWidth))
//        button.center = view.center
        button.setImage(UIImage(named: "refresh"), for: .normal)
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)

        reloadView!.addSubview(label)
        reloadView!.addSubview(button)
        self.view.addSubview(reloadView!)
        
    }
    @objc
    func reload(){
        print("IN RELOAD")
        if let _ = reloadView{
            reloadView?.removeFromSuperview()
        }
        if let view = self.distanceTimeView {
            view.removeFromSuperview()
        }
        if let line = self.polyline {
            line.map = nil
            
        }
        if !Connectivity.isConnectedToInternet{
            
            ProgressHUD.showError("Not connected to internet")
            configureFloatingReloadButton()
            //            self.configureFloatingButton()
            
        } else {
            print("IN ELSE")

            ProgressHUD.show("Reloading...")
            
            MapViewController.loadUsers(onSuccess: {
                MapViewController.loadLemonadeStands(view: self) {
                    
                    self.setMarkers()
                    self.configureFloatingButton()
                    self.configureTextField()
                    
                    ProgressHUD.showSuccess("Reloaded")
                }
            }, onFailure: {
                AuthService.logout(sender: self)
                ProgressHUD.showError("Failed")
            })
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
        
    }
    
    func transitionMapToStand(stand: Stand?){
        if let lemonadeStand = stand{
            self.mapView.camera = GMSCameraPosition(latitude: lemonadeStand.latitude!, longitude: lemonadeStand.longitude!, zoom: self.zoomLevel)
        }
    }
    
    func closeStandEarly(stand: Stand?){
        Database.database().reference().child(FirebaseNodes.stands).child(stand!.standId!).child(FirebaseNodes.endTime).setValue(Date().timeIntervalSince1970) { (error, ref) in
            if error == nil {
                ProgressHUD.showSuccess()
                self.reload()
            } else {
                ProgressHUD.showError("Failure closing stand...")
            }
        }
    }
    
    func presentEstablishBusinessAlert(){
        let alert = UIAlertController(title: "Establish your business!", message: "Go to your profile page and click Create It Now", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Default action"), style: .default, handler: { _ in
            alert.removeFromParent()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //floating right button
    //floaty library used
    func configureFloatingButton(){
        floaty.items = []
        floaty.buttonColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        floaty.plusColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        if MapViewController.currentUser.hasBusinessProfile! {
            
            floaty.addItem("Open stands", icon: UIImage(named: "open-button")!) { (item) in
                self.presentEstablishStandView()
            }
            
            if workingAStand {
                floaty.addItem("Close stands", icon: UIImage(named: "close-button")!) { (item) in
//                    self.closeStandEarly(stand: self.currentUsersStand)
                }
            }
//            floaty.addItem("Locate your Stand", icon: UIImage(named: "Lemon")!) { (item) in
//                self.transitionMapToStand(stand: self.currentUsersStand)
//            }
            
        } else {
            floaty.addItem("Establish your business first", icon: UIImage(named: "open-button")!) { (item) in
                self.presentEstablishBusinessAlert()
            }
        }

        floaty.addItem("Search for Users", icon: UIImage(named: "listview")) { (item) in
            self.presentListView()
        }
//        floaty.addItem("Corkboard", icon: UIImage(named: "corkboard")) { (item) in
//            self.performSegue(withIdentifier: "PresentCorkboard", sender: self)
//        }
        
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
}
extension MapViewController: UISearchBarDelegate{
    
    //floating textfield at the top of the screen
    //no internet needed
    func configureTextField(){
        
        let borderWidth = CGFloat(integerLiteral: 8)
        let backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        let borderColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
        
        let topBoxYStart: CGFloat = 42
        
        greetingLabel.frame =  CGRect(x: 16, y: topBoxYStart, width: view.bounds.width - 32, height: 42)
        greetingLabel.backgroundColor = backgroundColor
        greetingLabel.layer.borderColor = borderColor
        greetingLabel.layer.borderWidth = borderWidth - 2
        greetingLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        greetingLabel.font = UIFont.boldSystemFont(ofSize: greetingLabel.font.pointSize)
        
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 && hour > 3 {
            self.greetingLabel.text = "    Good Morning, \(MapViewController.currentUser.fullname!)"
        } else if hour < 17 {
            self.greetingLabel.text = "    Good Afternoon, \(MapViewController.currentUser.fullname!)"
        } else {
            self.greetingLabel.text = "    Good Evening, \(MapViewController.currentUser.fullname!)"
        }
        
        self.view.addSubview(greetingLabel)
        
        searchBar = UISearchBar(frame: CGRect(x: 16, y: greetingLabel.frame.maxY, width: view.bounds.width - 32, height: 42))
        
        searchBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchBar.layer.borderWidth = borderWidth
        searchBar.layer.borderColor = borderColor
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.placeholder = "Get directions by stand name"
        self.view.addSubview(searchBar)
        
    }
    
    func presentListView(){
        let listVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lemonadeStandListView")
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    func presentProfileView(user: User){
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        profileVC.setUser(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegue{
            let destination = segue.destination as! ProfileViewController
            destination.user = MapViewController.currentUser
        }
    }
    
    func presentEstablishStandView(){
        performSegue(withIdentifier: "ShowYourStands", sender: nil)
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
        MapViewController.filteredStands = MapViewController.activeStands.filter{ stand in
            let string = "\(stand.standName)"
            return(string.lowercased().contains(searchText.lowercased()))
        }
        tableView.reloadData()
    }
    
    //search bar text changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchBar)
        if MapViewController.filteredStands.count < 1 {
            tableView.removeFromSuperview()
        } else {
            self.view.addSubview(tableView)
        }
    }
}


extension MapViewController: GMSMapViewDelegate{
    
    static func loadCurrentUserStandsFromBusiness(onSuccess: @escaping() -> Void){
        MapViewController.currentUserStands = []
        Database.database().reference().child(FirebaseNodes.stands).observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? NSDictionary{
                for (_, stand) in snap {
                    if let dict = stand as? NSDictionary {
                        let newStand = Stand(dictionary: dict)
                        if newStand.userId == (Auth.auth().currentUser?.uid)! {
                            MapViewController.currentUserStands.append(newStand)
                        }
                    }
                }
                onSuccess()
            }
        }
    }
    
    static func resetAllStands() {
        lemonadeStands = []
        activeStands = []
        filteredStands = []
        currentUserStands = []
    }
    
    //loads all lemonade stands, checks if the currrent user is working a stand or not
    static func loadLemonadeStands(view: MapViewController, onSuccess: @escaping() -> Void){
        
        resetAllStands()
        //remove all markers from mapview
        view.mapView.clear()
        Database.database().reference().child(FirebaseNodes.stands).observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? NSDictionary{
                for (_, stand) in snap {
                    if let dict = stand as? NSDictionary {
                        let newStand = Stand(dictionary: dict)
                        newStand.setCreatorName(name: MapViewController.uidUserMap[newStand.userId]!.fullname)
                        MapViewController.lemonadeStands.append(newStand)
                        //check if this stand was created by the current user
                        if newStand.userId == (Auth.auth().currentUser?.uid)! {
                            MapViewController.currentUserStands.append(newStand)
                        }
                    }
                }
                onSuccess()
            } else {
                onSuccess()
            }
        }
    }
    
    func setMarkers(){
        workingAStand = false
        for stand in MapViewController.lemonadeStands{
            if stand.isOpen() {
                MapViewController.activeStands.append(stand)
                setMarker(stand: stand)
                if stand.userId == MapViewController.currentUser.uid {
                    workingAStand = true
                }
            }
        }
    }
    
    func setMarker(stand: Stand){
        let location = CLLocation(latitude: CLLocationDegrees(floatLiteral: stand.latitude!), longitude: CLLocationDegrees(floatLiteral: stand.longitude!))
        let marker = GMSMarker(position: location.coordinate)
        marker.icon = UIImage(named: "mapViewLemon")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let timestampDate = NSDate(timeIntervalSince1970: stand.endTime!)
        marker.map = mapView
        marker.title = "Stand Name: \(stand.standName!) | Created By: \(stand.creatorName!) | Closes At: \(dateFormatter.string(from: timestampDate as Date))"
        MapViewController.markerUserMap[marker] = MapViewController.uidUserMap[stand.userId!]
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.presentProfileView(user: MapViewController.markerUserMap[marker]!)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 120))
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
        
        
        let lbl3 = UILabel(frame: CGRect.init(x: lbl2.frame.origin.x, y: lbl2.frame.origin.y + lbl2.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl3.text = String((marker.title?.split(separator: "|")[2])!)
        lbl3.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl3)
        
        let profileButton = UIButton(frame: CGRect.init(x: view.frame.width - 64, y: lbl2.frame.origin.y + lbl2.frame.size.height + 24, width: view.frame.size.width - 16, height: 24))
        
        let horizontalCenter: CGFloat = view.bounds.size.width / 2.0
        profileButton.center = CGPoint(x: horizontalCenter, y: lbl3.frame.origin.y + lbl3.frame.size.height + 24)//horizontalCenter
        
        profileButton.setTitle("Click to View Profile", for: .normal)
        profileButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        profileButton.layer.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        profileButton.layer.cornerRadius = 6
        view.addSubview(profileButton)
        
        return view
    }
    
    static func reloadCurrentUser(onSuccess: @escaping() -> Void){
        let ref = Database.database().reference()
        ref.child(FirebaseNodes.users).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snap) in
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
        MapViewController.currentLocation = location
        
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
            return MapViewController.filteredStands.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = MapViewController.filteredStands[indexPath.row].standName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.clearButtonPressed()
        
        self.transitionMapToStand(stand: MapViewController.filteredStands[indexPath.row])
        
        //create directions from current location to stand
        self.drawPath(startLocation: locationManager.location!, endLocation: CLLocation(latitude: MapViewController.filteredStands[indexPath.row].latitude!, longitude: MapViewController.filteredStands[indexPath.row].longitude!))
        
        //remove table view
        tableView.removeFromSuperview()
        //remove keyboard
        searchBar.endEditing(true)
        
    }
    
    @objc
    func clearButtonPressed(){
        self.polyline?.map = nil
        self.distanceTimeView?.removeFromSuperview()
        self.clearButton?.removeFromSuperview()
    }
    
    func configureDistanceView(distance: String, time: String){
        
        clearButton = UIButton(frame: CGRect(x: 8, y: self.view.frame.height-138, width: 54, height: 24))
//        clearButton.layer.cornerRadius = 16
        
        guard let button = clearButton else {
            return
        }
        button.setTitle("Clear", for: .normal)
        button.layer.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        
        self.distanceTimeView = UIView(frame: CGRect(origin: CGPoint(x: 8, y: CGFloat(self.view.frame.height - 106)), size: CGSize(width: self.view.frame.width/2 - 25, height: 79)))
        
        guard let view = self.distanceTimeView else {
            return
        }
        let timePlaceholderLabel = UILabel(frame: CGRect(x: 0, y: 2, width: view.frame.width, height: 16))
        timePlaceholderLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        timePlaceholderLabel.text = "Time"
        timePlaceholderLabel.textAlignment = .center
        
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 18, width: view.frame.width, height: 16))
        timeLabel.text = time
        timeLabel.textAlignment = .center
        timeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        let distancePlaceholderLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height/2 + 4, width: view.frame.width, height: 16))
        distancePlaceholderLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        distancePlaceholderLabel.text = "Distance"
        distancePlaceholderLabel.textAlignment = .center
        let distanceLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height/2 + 16 + 4, width: view.frame.width, height: 16))
        distanceLabel.text = distance
        distanceLabel.textAlignment = .center
        distanceLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        view.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        self.view.addSubview(button)
         view.layer.cornerRadius = 12
         view.addSubview(timePlaceholderLabel)
         view.addSubview(timeLabel)
         view.addSubview(distancePlaceholderLabel)
         view.addSubview(distanceLabel)
        self.view.addSubview(view)
        
    }
    func getDistance(startLocation: CLLocation, endLocation: CLLocation){
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(origin)&destinations=\(destination)&key=\(ApiKeys.googleDistanceMatrixApiKey)"
        
        Alamofire.request(url, method: .get).responseJSON {(response) in
                if response.error == nil {
                    do {
                        let json : JSON  = try JSON(data: response.data!)
                        let elements = json["rows"][0]["elements"].arrayValue
                        
                        let distanceString = elements[0]["distance"]["text"].stringValue
                        let timeString = elements[0]["duration"]["text"].stringValue
                        
                        self.configureDistanceView(distance: distanceString, time: timeString)
                        
                        print(distanceString)
                    } catch {
                        print(error)
                    }
                } else {
                    ProgressHUD.showError("Error getting directions")
                }
        }
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation){
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(ApiKeys.googleDirectionsApiKey)"
        Alamofire.request(url, method: .get).responseJSON {(response) in
            if response.error == nil {
                do {
                    let json : JSON  = try JSON(data: response.data!)
                    let routes = json["routes"].arrayValue
                    
                    //distance = json["routes"][0]["legs"][1]
                    for route in routes{
                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                        let points = routeOverviewPolyline?["points"]?.stringValue
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        
                        polyline.strokeWidth = 4
                        polyline.strokeColor = UIColor.red
                        polyline.map = self.mapView
                        self.polyline = polyline
                        
                        self.getDistance(startLocation: startLocation, endLocation: endLocation)
                    }
                } catch {
                    print(error)
                }
                
            } else {
                ProgressHUD.showError("Error getting directions")
            }
        }
        
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

extension MapViewController{//bulletin board functions
    static func getStandsFromUsersSchool() -> [Stand]{
//        if currentUser.school == nil {
//            return []
//        }
//
        
        var stands:[Stand] = []
//        for stand in MapViewController.lemonadeStands{
//            
//            if let otherUserSchool = MapViewController.uidUserMap[stand.userId]?.school{
//                
//                if otherUserSchool.lowercased() == currentUser.school!.lowercased() && Date() < Date(timeIntervalSince1970: TimeInterval(integerLiteral: stand.endTime)) {
//                    stands.append(stand)
//                }
//            }
//            
//        }
        return stands
    }
    
    static func getStandsFrom(city: String) -> [Stand] {
        var stands:[Stand] = []
        
//        for stand in MapViewController.lemonadeStands{
//            if stand.city.lowercased() == city.lowercased() && Date() < Date(timeIntervalSince1970: TimeInterval(integerLiteral: stand.endTime!)){
//                stands.append(stand)
//            }
//        }
        return stands
    }
    
    static func getStandsClosingSoon() -> [Stand]{
        var stands:[Stand] = []
        let date = Date()
        let hoursToAdd = 1
        let newDate = Calendar.current.date(byAdding: .hour, value: hoursToAdd, to: Date())
        for stand in MapViewController.lemonadeStands{
            if Date(timeIntervalSince1970: TimeInterval(integerLiteral: stand.endTime!)) <= newDate! && Date(timeIntervalSince1970: TimeInterval(integerLiteral: stand.endTime!)) > date {
                stands.append(stand)
            }
        }
        return stands
    }
}


