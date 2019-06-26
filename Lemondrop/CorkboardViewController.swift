//
//  CorkboardViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD


import GoogleMaps
import GooglePlaces
import CoreLocation

class CorkboardViewController: UIViewController{
    
    
    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var noStandsLabel: UILabel?
    var standsShowing = [LemonadeStand](){
        didSet{
            
            noStandsLabel?.removeFromSuperview()
            if standsShowing.count == 0{
                configureNoStandsLabel()
            } 
        }
    }
    
    static let cellIdentifier = "StickyNote"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        standsShowing = MapViewController.getStandsFromUsersSchool()
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        establishSegmentControlTitles()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return collectionView.backgroundView
    }
    
    func configureNoStandsLabel(){
        self.noStandsLabel = UILabel(frame: CGRect(x: (self.view.frame.width/2 - 50), y: (self.view.frame.height/2 - 50), width: 100, height: 100))
        noStandsLabel!.text = "0 Stands"
        noStandsLabel!.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(noStandsLabel!)
    }
}

extension CorkboardViewController{//segment controller / filter
    
    func establishSegmentControlTitles(){
        
        if let school = MapViewController.currentUser.school{
            filter.setTitle( school, forSegmentAt: 0)// = MapViewController.currentUser.school!
        } else {
            filter.setTitle("N/A", forSegmentAt: 0)
        }
        
        
        filter.setTitle("Closing Soon", forSegmentAt: 2)
        
        //
        
        

        if CLLocationManager.locationServicesEnabled(){
            
        switch CLLocationManager.authorizationStatus(){
            case .notDetermined, .restricted,.denied:
                
                print("Location not enabled")
                self.filter.setTitle("No Location", forSegmentAt: 1)
                return
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access granted")
                
            }
        } else {
            
            
            print("Location not enabled")
            self.filter.setTitle("No Location", forSegmentAt: 1)
            return
        }
        
        guard let locationLatitude = (MapViewController.currentLocation?.coordinate.latitude) else {
            
            self.filter.setTitle("No Location", forSegmentAt: 1)
            print("error getting location latitude")
            return
        }
        guard let locationLongitude = (MapViewController.currentLocation?.coordinate.longitude) else {
            
            self.filter.setTitle("No Location", forSegmentAt: 1)
            print("error getting location longitutde")
            return
        }
        
        guard let url = URL(string:  "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(locationLatitude),\(locationLongitude)&key=\(ApiKeys.googleMapsApiKey)") else {
            return
        }
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let googleJSON : JSON = JSON(response.result.value!)
                    print(googleJSON["results"][0]["address_components"][3]["long_name"])
                    self.filter.setTitle(googleJSON["results"][0]["address_components"][3]["long_name"].string, forSegmentAt: 1)
                    return
                } else {
                     self.filter.setTitle("No Location", forSegmentAt: 1)
                }
        }
        
        
    }
    
    @IBAction func filterClicked(_ sender: Any) {
        if filter.selectedSegmentIndex == 0 {
            standsShowing = MapViewController.getStandsFromUsersSchool()
        } else if filter.selectedSegmentIndex == 1 {
            standsShowing = MapViewController.getStandsFrom(city: filter.titleForSegment(at: 1)!)
            
        } else if filter.selectedSegmentIndex == 2{
            standsShowing = MapViewController.getStandsClosingSoon()
            
        }
        collectionView.reloadData()
    }
}

extension CorkboardViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return standsShowing.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickyNote", for: indexPath) as! StickyNote
        cell.configureCell(stand: standsShowing[indexPath.row])
        return cell
    }
}
