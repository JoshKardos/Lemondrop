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
        
        
        
        //save into database user(username, email, major, school profileImage,...)
        usersRef.child(uid).setValue(["fullname": fullname, "email" : email, "school": school, "age": age, "uid": uid])
        
        onSuccess()
    }
}
