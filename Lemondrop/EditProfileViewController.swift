//
//  EditProfileViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseAuth
class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var businessViewContainer: UIView!
    @IBOutlet weak var businessStandsLabel: UILabel!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var standsTableView: UITableView!
    @IBOutlet weak var businessNameTextField: UITextField!
    var fullnameIsUnique = true
    var businessNameIsUnique = true
    @IBOutlet weak var fullnameActivityBar: UIActivityIndicatorView!
    @IBOutlet weak var businessNameActivityBar: UIActivityIndicatorView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullnameTextField.text = MapViewController.currentUser.fullname!
        
        // Do any additional setup after loading the view.
        fullnameActivityBar.isHidden = true
        fullnameTextField.addTarget(self, action: #selector(fullNameFieldDidChange(_:)), for: .editingChanged)
        
        businessNameTextField.text = MapViewController.currentUsersBusiness?.name!
        businessNameActivityBar.isHidden = true
        businessNameTextField.addTarget(self, action: #selector(businessNameFieldDidChange(_:)), for: .editingChanged)
        standsTableView.dataSource = self
        configureTableView()
    }
    
    func configureTableView() {
        if !MapViewController.currentUser.hasBusinessProfile! {
            businessViewContainer.isHidden = true
        } else {
            guard let businessName = MapViewController.currentUsersBusiness?.name else {
                fatalError()
            }
            businessStandsLabel.text = "\(businessName) stands"
            standsTableView.addSubview(self.refreshControl)
        }
    }
    
    @objc
    func refresh(_ refreshControl: UIRefreshControl) {
        MapViewController.loadCurrentUserStandsFromBusiness(onSuccess: {
            self.standsTableView.reloadData()
        })
        refreshControl.endRefreshing()
    }
    
    var timer: Timer?
    @objc func handleFullnameAnimation(){
        DispatchQueue.main.async {
            self.fullnameActivityBar.stopAnimating()
            self.fullnameActivityBar.isHidden = true
        }
    }
    @objc func handleBusinessnameAnimation(){
        DispatchQueue.main.async {
            self.businessNameActivityBar.stopAnimating()
            self.businessNameActivityBar.isHidden = true
        }
    }
    
    @objc func fullNameFieldDidChange(_ textField: UITextField) {
        checkIsUniqueFullname { (bool) in
            self.fullnameActivityBar.isHidden = false
            self.fullnameActivityBar.startAnimating()
            if bool{
                self.fullnameTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
                self.fullnameTextField.layer.borderWidth = 0.0
                self.fullnameIsUnique = true
            } else {
                self.fullnameTextField.layer.borderWidth = 2.0
                self.fullnameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                self.fullnameIsUnique = false
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleFullnameAnimation), userInfo: nil, repeats: false)
        }
    }
    
    @objc func businessNameFieldDidChange(_ textField: UITextField) {
        checkIsUniqueBusinessname { (bool) in
            self.businessNameActivityBar.isHidden = false
            self.businessNameActivityBar.startAnimating()
            if bool{
                self.businessNameTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
                self.businessNameTextField.layer.borderWidth = 0.0
                self.businessNameIsUnique = true
            } else {
                self.businessNameTextField.layer.borderWidth = 2.0
                self.businessNameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                self.businessNameIsUnique = false
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleBusinessnameAnimation), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if !self.validTextFields(){
            return
        }
        let ref = Database.database().reference()
        let oldFullname = MapViewController.currentUser.fullname
        ProgressHUD.show()
        let fullnameValues = ["fullname": fullnameTextField.text!]
        let businessNameValues = ["name": businessNameTextField.text!]
        ref.child(FirebaseNodes.users).child((Auth.auth().currentUser?.uid)!).updateChildValues(fullnameValues) { (error, ref) in
            if error == nil {
                
                //delete old username from database
                Database.database().reference().child(FirebaseNodes.fullnames).child(oldFullname!).removeValue()
                Database.database().reference().child(FirebaseNodes.fullnames).child(self.fullnameTextField.text!).setValue(1)
                
                //delete old business name
                Database.database().reference().child(FirebaseNodes.businessNames).child(MapViewController.currentUsersBusiness!.name!).removeValue()
                Database.database().reference().child(FirebaseNodes.businessNames).child(self.businessNameTextField.text!).setValue(1)
                
                Database.database().reference().child(FirebaseNodes.businesses).child(ProfileViewController.businessId).updateChildValues(businessNameValues) { (error, ref) in
                    if error == nil {
                        MapViewController.reloadCurrentUser()
                        ProgressHUD.showSuccess("Successfully changed your information")
                    } else {
                        ProgressHUD.showError("Could not update your records")
                    }
                }
            } else {
                ProgressHUD.showError("Could not update your records")
            }
        }
        
        
        
    }
    
    func checkIsUniqueBusinessname(completion: @escaping (Bool)->()){
        Database.database().reference().child(FirebaseNodes.businessNames).observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String: Any] {
                for (name, _) in dict {
                    if name == self.businessNameTextField.text && name != MapViewController.currentUsersBusiness!.name! {
                        completion(false)
                        return
                    }
                }
                completion(true)
            } else {
                completion(true)
            }
        }
        
    }
    
    func checkIsUniqueFullname(completion: @escaping (Bool)->()){
        Database.database().reference().child(FirebaseNodes.fullnames).observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String: Any] {
                for (name, _) in dict {
                    if name == self.fullnameTextField.text && name != MapViewController.currentUser.fullname!{
                        completion(false)
                        return
                    }
                }
                completion(true)
            }
        }
        completion(true)
        
    }
    func validTextFields() -> Bool{
        
        if !fullnameIsUnique && !businessNameIsUnique {
            ProgressHUD.showError("Username and business name must be unique")
            return false

        }
        if !fullnameIsUnique {
            ProgressHUD.showError("Username must be unique")
            return false
        }
        if !businessNameIsUnique {
            ProgressHUD.showError("Business name must be unique")
            return false
        }
        
        if fullnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || businessNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            ProgressHUD.showError("Must not have an empty field")
            return false
        }
        
        return true
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapViewController.currentUserStands.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileStandCell", for: indexPath)
        if indexPath.row < MapViewController.currentUserStands.count {
            cell.textLabel?.text = MapViewController.currentUserStands[indexPath.row].standName
        }
        return cell
    }
}
