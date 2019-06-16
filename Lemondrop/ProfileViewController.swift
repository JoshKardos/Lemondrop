//
//  ProfileViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 5/25/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseAuth
import Cosmos
import SideMenu
import FirebaseDatabase
import ProgressHUD
import StoreKit
class ProfileViewController: UIViewController{
    
    static var hatNames = ["white-hat", "blue-hat", "goldhat"]
    static var shirtNames = ["white-shirt", "blue-shirt", "goldshirt"]
    static var pantNames = ["white-pants", "blue-pants", "goldpants"]
    let avatarBackgroundColor: CGColor =  #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    var hatIndex = Int(){
        didSet{
            hatImage.image = UIImage(named: ProfileViewController.hatNames[hatIndex])
            print(ProfileViewController.hatNames[hatIndex])
            if !user.unlockedHats.contains(String(hatIndex)){
                hatImage.layer.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                enableLockButton(button: hatLockButton)
            }
            else {
                hatImage.layer.backgroundColor = avatarBackgroundColor
                disableLockButton(button: hatLockButton)
            }
            
        }
    }
    var shirtIndex = Int(){
        didSet{
            
            shirtImage.image = UIImage(named: ProfileViewController.shirtNames[shirtIndex])
            if !user.unlockedShirts.contains(String(shirtIndex)){
                shirtImage.layer.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                enableLockButton(button: shirtLockButton)
                
            }
            else {
                shirtImage.layer.backgroundColor = avatarBackgroundColor
                disableLockButton(button: shirtLockButton)
            }
            
        }
    }
    var pantsIndex = Int(){
        didSet{
            
            pantsImage.image = UIImage(named: ProfileViewController.pantNames[pantsIndex])
            
            if !user.unlockedPants.contains(String(pantsIndex)){
                pantsImage.layer.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                enableLockButton(button: pantsLockButton)
                
            }
            else {
                pantsImage.layer.backgroundColor = avatarBackgroundColor
                disableLockButton(button: pantsLockButton)
            }
            
        }
    }
    
    @IBOutlet weak var hatLockButton: UIButton!
    @IBOutlet weak var shirtLockButton: UIButton!
    @IBOutlet weak var pantsLockButton: UIButton!
    
    @IBOutlet weak var hatImage: UIImageView!
    @IBOutlet weak var shirtImage: UIImageView!
    @IBOutlet weak var pantsImage: UIImageView!
    
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var schoolField: UILabel!
    @IBOutlet weak var ageField: UILabel!
    
    @IBOutlet weak var submitRatingButton: UIButton!
    @IBOutlet weak var ratingStars: CosmosView!
    var user: User!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet var outfitArrows: [UIButton]!
    @IBOutlet weak var submitOutfitButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Profile"
        ratingStars.settings.fillMode = .precise
        configureView()
        SKPaymentQueue.default().add(self)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("profile appeared")
        navigationController?.isNavigationBarHidden = false
        
        
        guard let uid = Auth.auth().currentUser?.uid else {
            performSegue(withIdentifier: "ToMainStoryboard", sender: self)
            return
        }
        
        print(uid)
        
        
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    func configureView(){
        
        nameField.text = user.fullname!
        schoolField.text = user.school!
        ageField.text = user.ageString!
        
        if user.uid == Auth.auth().currentUser?.uid{//if current user
            
            let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.settingsTapped))
            self.navigationItem.setRightBarButton(settingsButton, animated: true)
            
            self.submitRatingButton.isHidden = true
            disableRating()
            
        } else {//not current user
            
            ratingStars.didFinishTouchingCosmos = { rating in
                
                self.allowRating()
            }
            
            self.disableArrows()
            
        }
        
        let hatIndex = Int(self.user.avatar["hatIndex"]!)!
        let shirtIndex = Int(self.user.avatar["shirtIndex"]!)!
        let pantsIndex = Int(self.user.avatar["pantsIndex"]!)!
        
        self.hatIndex = hatIndex
        self.shirtIndex = shirtIndex
        self.pantsIndex = pantsIndex
        
        loadRating()
        
    }
    
    @IBAction func saveOutfitPressed(_ sender: Any) {
        
        
        if !user.unlockedHats.contains(String(hatIndex)) || !user.unlockedShirts.contains(String(shirtIndex)) || !user.unlockedPants.contains(String(pantsIndex)){
            
            print("ERROR")
            ProgressHUD.showError("You have not unlocked all of these clothes yet")
            return
        } else if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Check internet connection")
            return
        }
        
        let newAvatarValue = ["hatIndex": String(hatIndex), "shirtIndex": String(shirtIndex), "pantsIndex": String(pantsIndex)] 
        
        
        let ref = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("avatar")
        ref.updateChildValues(newAvatarValue) { (error, ref) in
            
            if error == nil{
                MapViewController.reloadCurrentUser {
                    
                    ProgressHUD.showSuccess("Set your new clothes")
                }
            } else {
                ProgressHUD.showError("Error setting your new clothes")
            }
            
        }
        //
        
    }
    @IBAction func submitRatingPressed(_ sender: Any) {
        
        Database.database().reference().child("user-rated").child((Auth.auth().currentUser?.uid)!).child(user.uid!).setValue(1) { (error, ref) in
            
            
            
            
            
            let ref = Database.database().reference().child("user-ratings").child(self.user.uid!).childByAutoId()
            let values = ["ratingId": ref.key!, "score": self.ratingStars.rating, "raterId": (Auth.auth().currentUser?.uid)!] as [String : Any]
            
            ref.setValue(values) { (error, ref) in
                if error == nil{
                    self.disableRating()
                    
                    ProgressHUD.showSuccess()
                } else {
                    ProgressHUD.showError("Couldn't add your rating")
                }
            }
        }
    }
    var iapAvatarNodeToAdjust: String?
    var indexToBuy: Int?
    var iapProductId: String?
    //button to unlock when successfully purchased
    @IBAction func hatLockButtonClicked(_ sender: Any) {
        iapAvatarNodeToAdjust = "unlockedHats"
        indexToBuy = hatIndex
        iapProductId = "com.JoshKardos.Lemondrop.PremiumOutfit.\(ProfileViewController.hatNames[indexToBuy!])"
        self.handleLockClick()
    }
    @IBAction func shirtButtonClicked(_ sender: Any) {
        
        iapAvatarNodeToAdjust = "unlockedShirts"
        indexToBuy = shirtIndex
        iapProductId = "com.JoshKardos.Lemondrop.PremiumOutfit.\(ProfileViewController.shirtNames[indexToBuy!])"
        self.handleLockClick()
    }
    @IBAction func pantsButtonClicked(_ sender: Any) {
        
        iapAvatarNodeToAdjust = "unlockedPants"
        indexToBuy = pantsIndex
        iapProductId = "com.JoshKardos.Lemondrop.PremiumOutfit.\(ProfileViewController.pantNames[indexToBuy!])"
        self.handleLockClick()
    }
    
    func handleLockClick(){
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = self.iapProductId!
            SKPaymentQueue.default().add(paymentRequest)
        } else {//cant make payments
            
        }
    }
    
    func disableRating(){
        self.submitRatingButton.isEnabled = false
        self.ratingStars.isUserInteractionEnabled = false
    }
    func allowRating(){
        self.submitRatingButton.isEnabled = true
        self.submitRatingButton.isHidden = false
    }
    func setUser(user: User){
        self.user = user
    }
    func loadRating(){
        
        
        if !Connectivity.isConnectedToInternet{
            
            self.ratingStars.rating = 0.0
            return
        }
        Database.database().reference().child("user-ratings").child(user.uid!).observe(.value) { (snapshot) in
            
            if let snap = snapshot.value as? NSDictionary{
                
                var totalScore: Double = 0.0
                let numRatings = snap.count
                for (_, rating) in snap {
                    
                    if let dict = rating as? NSDictionary {
                        
                        totalScore += dict["score"] as! Double
                    }
                    
                }
                
                self.ratingStars.rating = ( totalScore / Double(numRatings) )
                self.ratingLabel.text = "Rating: \( totalScore / Double(numRatings))"
                
            } else {
                self.ratingLabel.text = "Rating: NONE"
                self.ratingStars.rating = 0.0
            }
        }
    }
    @objc func settingsTapped(){
        
        performSegue(withIdentifier: "presentSettings", sender: nil)
        
    }
    
    
}

extension ProfileViewController{//hadnle avatar view
    
    func enableLockButton(button: UIButton){
        if user.uid == Auth.auth().currentUser?.uid{
            button.isEnabled = true
            button.isHidden = false
        }
    }
    func disableLockButton(button: UIButton){
        button.isEnabled = false
        button.isHidden = true
    }
    func disableArrows(){
        
        for button in outfitArrows{
            button.isHidden = true
            button.isEnabled = false
            
        }
        submitOutfitButton.isEnabled = false
        submitOutfitButton.isHidden = true
        
        hatLockButton.isEnabled = false
        shirtLockButton.isEnabled = false
        pantsLockButton.isEnabled = false
        
        hatLockButton.isHidden = true
        shirtLockButton.isHidden = true
        pantsLockButton.isHidden = true
    }
    
    func handleLeftArrow(index: inout Int, staticArray: [String]){
        if index - 1 < 0{
            index = staticArray.count - 1
        } else {
            index -= 1
        }
        
    }
    
    //changing avatar image to the right
    func handleRightArrow(index: inout Int, staticArray: [String]){
        if index + 1 > staticArray.count - 1{
            index = 0
        } else {
            index += 1
        }
        
    }
    //changing avatar image to the left
    @IBAction func hatLeftPressed(_ sender: Any) {
        
        handleLeftArrow(index: &self.hatIndex, staticArray: ProfileViewController.hatNames)
        
    }
    @IBAction func hatRightPressed(_ sender: Any) {
        handleRightArrow(index: &hatIndex, staticArray: ProfileViewController.hatNames)
    }
    @IBAction func shirtLeftPressed(_ sender: Any) {
        handleLeftArrow(index: &shirtIndex, staticArray: ProfileViewController.shirtNames)
    }
    @IBAction func shirtRightPressed(_ sender: Any) {
        handleRightArrow(index: &shirtIndex, staticArray: ProfileViewController.shirtNames)
    }
    @IBAction func pantsLeftPressed(_ sender: Any) {
        handleLeftArrow(index: &pantsIndex, staticArray: ProfileViewController.pantNames)
    }
    @IBAction func pantsRightPressed(_ sender: Any) {
        handleRightArrow(index: &pantsIndex, staticArray: ProfileViewController.pantNames)
    }
    
}
extension ProfileViewController: SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased{
                print("Transaction successful")
                purchaseOutfit()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed{
                print("Transaction failed")
                
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    ProgressHUD.showError("Failed: \(errorDescription)")
                    print("Transaction failed due to error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored{
                print("Transaction restored")
                purchaseOutfit()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func purchaseOutfit(){
        
        //add to current user node
        print(self.iapAvatarNodeToAdjust!)
        print(Auth.auth().currentUser!.uid)
        let ref = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child(self.iapAvatarNodeToAdjust!)
        
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            ref.child(String(snapshot.childrenCount)).setValue(String(self.indexToBuy!))
            MapViewController.reloadCurrentUser() {
                self.user = MapViewController.currentUser
                self.configureView()
            }
            
        }
        
        
    }
    
    static func logOutAndPresentSignUpView(){
        
        AuthService.logout(sender: nil)
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("profile disapperaing")
    }
}
