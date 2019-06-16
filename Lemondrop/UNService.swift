//
//  UNService.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/9/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class UNService: NSObject{
    private override init() {
    }
    
    static let shared = UNService()
    
    let unCenter = UNUserNotificationCenter.current()
    
    func authorize(){
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        
        unCenter.requestAuthorization(options: options) { (granted, error) in
            print(error ?? "no authorization error")
            
            guard granted else {return}
            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
    
    func configure(){
        
        print("inside configure")
        unCenter.delegate = self
        
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        
        
    }
}

extension UNService: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive un")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present un")
        completionHandler([])
        
    }
}
