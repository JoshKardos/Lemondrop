//
//  SNSService.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/11/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation

import AWSSNS
import FirebaseAuth
class SNSService{
    
    
    private init() {}
    static let shared = SNSService()
    static var deviceEndpoint: String?
    static let topicArnPlaceholder = "arn:aws:sns:us-west-1:597067832927:"
    func configure(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: ApiKeys.awsAccessKeyID, secretKey: ApiKeys.awsSecretAccessKey)
        
        let serviceConfigurations = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default()?.defaultServiceConfiguration = serviceConfigurations
    }
    
    func register(){
        
        print("registering")
        let arn = "arn:aws:sns:us-west-1:597067832927:app/APNS_SANDBOX/Lemondrop"
        
        guard let platformEndpointRequest = AWSSNSCreatePlatformEndpointInput() else { return }
        guard let currentUid = (Auth.auth().currentUser?.uid) else { return }
        
        platformEndpointRequest.customUserData = currentUid
        platformEndpointRequest.token = User.current.token
        platformEndpointRequest.platformApplicationArn = arn
        AWSSNS.default().createPlatformEndpoint(platformEndpointRequest).continueWith { (task) -> Any?
            
            in
            
            guard let endpoint = task.result?.endpointArn else {
                print("returning inregister1")
                print(SNSService.deviceEndpoint)
                return nil }
            print("SNSSERVICEENDPOINT \(SNSService.deviceEndpoint)")
            print("ENDPOINT \(endpoint)")
            
            SNSService.deviceEndpoint = endpoint
            
            guard let topicInput = AWSSNSCreateTopicInput() else {
                print("returning inregister2")
                return nil }
            
            topicInput.name = currentUid
            
            AWSSNS.default().createTopic(topicInput).continueOnSuccessWith { (task) -> Any? in
                
                self.subscribe(to: endpoint)
                
                return nil
            }
            return nil
        }
        
        
    }
    
    func subscribe(to endpoint: String){
        
        guard let subscribeRequest = AWSSNSSubscribeInput() else {return}
        
        
        subscribeRequest.topicArn = SNSService.topicArnPlaceholder + Auth.auth().currentUser!.uid
        subscribeRequest.protocols = "application"
        subscribeRequest.endpoint = endpoint
        
        
        AWSSNS.default().subscribe(subscribeRequest).continueWith { (task) -> Any? in
            print(task.error ?? "successuflly subscribed to topic")
            return nil
        }
    }
    static func unsubscribe(subscriptionArn: String?){
        
       let unsubscribeInput = AWSSNSUnsubscribeInput()
        unsubscribeInput?.subscriptionArn = subscriptionArn
        AWSSNS.default().unsubscribe(unsubscribeInput!).continueWith { (task) -> Any? in
    
            return nil
            
        }
    }
    
    
    
    static func deleteSubscriptions(){
        print("CALLED delete subscriptions")
        let listSubscriptionsRequest = AWSSNSListSubscriptionsInput()
        AWSSNS.default().listSubscriptions(listSubscriptionsRequest!).continueWith { (task) -> Any? in
            
            
            if task.error != nil {
                return nil
            }
            let response = task.result
            for subscription in response!.subscriptions! {
                
                if subscription.endpoint == SNSService.deviceEndpoint {
                    SNSService.unsubscribe(subscriptionArn: subscription.subscriptionArn)
                   
                    let deleteEndpointRequest = AWSSNSDeleteEndpointInput()
                    deleteEndpointRequest?.endpointArn = subscription.endpoint
                    AWSSNS.default().deleteEndpoint(deleteEndpointRequest!)
                }
                
                
            }
            
            
            
            return nil
            
            
        }
    }
    
    func publish(description: String, from sender: User, to receiver: User){
        
        guard let publishRequest = AWSSNSPublishInput() else { return }
        
        publishRequest.messageStructure = "json"
        
        let dict = ["default": description,
            "APNS_SANDBOX": "{\"aps\":{\"alert\":\"\(description)\(sender.fullname!)\"}}"
            
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            
            
            publishRequest.message = String(data: jsonData, encoding: .utf8)
            publishRequest.topicArn = SNSService.topicArnPlaceholder + receiver.uid!
            AWSSNS.default().publish(publishRequest).continueWith { (task) -> Any? in
                
                
                print(task.error ?? "published message")
                return nil
                
            }
            
        } catch {
            print(error)
            
        }
    }
    
    
}
