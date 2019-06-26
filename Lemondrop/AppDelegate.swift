//
//  AppDelegate.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/16/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import AWSSNS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        
        GMSServices.provideAPIKey(MapViewController.googleMapsApiKey)
        GMSPlacesClient.provideAPIKey(MapViewController.googleMapsApiKey)
    
        UNService.shared.authorize()
        SNSService.shared.configure()
        
        FirebaseApp.configure()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register for un")
    
        let token = deviceToken.reduce(""){ $0 + String(format: "%02X", $1)}
        print(token)
        User.current.token = token
    }
    
    
}

