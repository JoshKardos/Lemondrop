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
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        
        GMSServices.provideAPIKey(MapViewController.googleMapsApiKey)
        GMSPlacesClient.provideAPIKey(MapViewController.googleMapsApiKey)
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ApiKeys.oneSignalAppId,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        
        })
        
        
//        SNSService.shared.configure()
//        
        FirebaseApp.configure()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register for un")
    
        let token = deviceToken.reduce(""){ $0 + String(format: "%02X", $1)}
        print("token \(token)")
        User.current.token = token
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

