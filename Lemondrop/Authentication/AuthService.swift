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
class AuthService {
    
    
    static func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            onSuccess()
            
        }
    }
    static func logout(sender: UIViewController){
        
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            
            sender.present(signInVC, animated: true, completion: nil)
            
        } catch let logoutError{
            
            print(logoutError)
            
        }
    }
    
    static func signUp(fullname: String, email: String, password: String, school: String, age: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        
        /////////////////////
        ////Create User//////
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
    
    static func signUpUser(fullname: String, email: String, uid: String,  school: String, age: String, onSuccess: @escaping () -> Void){
        
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
        
        usersRef.child(uid).setValue(["fullname": fullname, "email" : email, "school": school, "age": age, "uid": uid, "avatar": initialAvatarValues, "unlockedHats": initialUnlockedHats, "unlockedShirts": initialUnlockedShirts, "unlockedPants": initialUnlockedPants])
        
        
        onSuccess()
    }
}
