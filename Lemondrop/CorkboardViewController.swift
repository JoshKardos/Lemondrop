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
class CorkboardViewController: UIViewController{
    
    
    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var standsShowing = [LemonadeStand]()
    
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

}
extension CorkboardViewController{//segment controller / filter
    
    func establishSegmentControlTitles(){
        filter.setTitle( MapViewController.currentUser.school!, forSegmentAt: 0)// = MapViewController.currentUser.school!
        guard let url = URL(string:  "https://maps.googleapis.com/maps/api/geocode/json?latlng=\((MapViewController.currentLocation?.coordinate.latitude)!),\((MapViewController.currentLocation?.coordinate.longitude)!)&key=\(ApiKeys.googleMapsApiKey)") else {
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
                     self.filter.setTitle("N/A", forSegmentAt: 1)
                }
        }
        
    }
    
    @IBAction func filterClicked(_ sender: Any) {
        if filter.selectedSegmentIndex == 0 {
            standsShowing = MapViewController.getStandsFromUsersSchool()
            print(0)
        } else if filter.selectedSegmentIndex == 1 {
            standsShowing = MapViewController.getStandsFrom(city: filter.titleForSegment(at: 1)!)
            print(1)
        } else if filter.selectedSegmentIndex == 2{
            standsShowing = MapViewController.getStandsClosingSoon()
            print(2)
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
