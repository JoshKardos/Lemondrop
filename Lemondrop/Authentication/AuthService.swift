//
//  AuthService.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/17/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD
import OneSignal
class AuthService {
    
    
    static func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            AuthService.addPlayerId()
            onSuccess()
            
        }
    }
    static func logout(sender: UIViewController?){
        
        do {
            
            AuthService.deletePlayerId()

            
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
//            SNSService.deleteSubscriptions()
            
            if let sender = sender {
                sender.present(signInVC, animated: true, completion: nil)
            } 
            
            
            
            
        } catch let logoutError{
            
            print(logoutError)
            
        }
    }
    
    static func signUp(fullname: String, email: String, password: String, school: String?, age: String?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        
        /////////////////////
        ////Create User/////
        /////////////////////
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("Eror creating user: \(error!.localizedDescription)")
                onError(error!.localizedDescription)
                return
            }
            
            
            
            if let uid = Auth.auth().currentUser?.uid{
                
                self.signUpUser(fullname: fullname, email: email, uid: uid, school: school, age: age, onSuccess: onSuccess)
            }
        }
        
    }
    
    
    
    static func signUpUser(fullname: String, email: String, uid: String,  school: String?, age: String?, onSuccess: @escaping () -> Void){
        
        //get referenece to users in the database
        let usersRef = Database.database().reference().child("users")

        
        let initialAvatarValues = ["hatIndex": "0", "shirtIndex": "0", "pantsIndex": "0"]
        
        
        var initialUnlockedHats = [String: String]()
        initialUnlockedHats["0"] = "0"
        initialUnlockedHats["1"] = "1"
        var initialUnlockedShirts = [String: String]()
        initialUnlockedShirts["0"] = "0"
        initialUnlockedShirts["1"] = "1"
        var initialUnlockedPants = [String: String]()
        initialUnlockedPants["0"] = "0"
        initialUnlockedPants["1"] = "1"
        
        
        var values = ["fullname": fullname, "email" : email, "uid": uid,
                     "avatar": initialAvatarValues, "unlockedHats": initialUnlockedHats,
                     "unlockedShirts": initialUnlockedShirts, "unlockedPants": initialUnlockedPants] as [String : Any]
        
        if school?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            values["school"] = school
        }
        if age?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            values["age"] = age
        }
        
        usersRef.child(uid).setValue(values)
        Database.database().reference().child("fullnames").updateChildValues([fullname : 1])
        AuthService.addPlayerId()
        onSuccess()
        
    }
    
    static func addPlayerId(){
        
        
        guard let playerId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId else {
            return
        }
        Database.database().reference().child("user-playerIds").child((Auth.auth().currentUser?.uid)!).updateChildValues([playerId:"1"])//setValue( [playerId : 1] )
        
    }
    static func deletePlayerId(){
        guard let playerId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId else {
            print("Bad playerid")
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Bad uid")
            return
        }
        Database.database().reference().child("user-playerIds").child(uid).child(playerId).removeValue { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
        }
        
    }
    static func setToken(){
        
//        print("SETTING TOKEN")
//
//        let token = UserDefaults.standard.string(forKey: "token")
//
//        guard let _ = token  else {
//            return
//        }
////        User.current.token = token!
//        SNSService.shared.register()
        
    }
    
    static func reauthenticateUser(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void){
        
        let user = Auth.auth().currentUser;
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        //https://stackoverflow.com/questions/38253185/re-authenticating-user-credentials-swift
    
        user?.reauthenticate(with: credential, completion: { (result, error) in
            
            if error != nil {
                onError((error?.localizedDescription)!)
                return
            }
            
            onSuccess()
            return
            
        })
    }
}

