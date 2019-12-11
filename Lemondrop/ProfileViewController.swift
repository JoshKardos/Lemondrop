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
import HYParentalGate
class ProfileViewController: UIViewController{
    
    static var hatNames = ["white-hat", "blue-hat", "goldhat"]
    static var shirtNames = ["white-shirt", "blue-shirt", "goldshirt"]
    static var pantNames = ["white-pants", "blue-pants", "goldpants"]
    
   
    @IBOutlet weak var bottomScrollView: UIScrollView!
    
    let avatarBackgroundColor: CGColor =  #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    var hatIndex = Int(){
        didSet{
            hatImage.image = UIImage(named: ProfileViewController.hatNames[hatIndex])
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
    @IBOutlet weak var businessNameLeftLabel: UILabel!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var standTotalLeftLabel: UILabel!
    @IBOutlet weak var standTotalLabel: UILabel!
    @IBOutlet weak var bpNotCreatedLabel: UILabel!
    @IBOutlet weak var createBPButton: UIButton!
    
    @IBOutlet weak var submitRatingButton: UIButton!
    @IBOutlet weak var ratingStars: CosmosView!
    var user: User!
    static var businessId: String! // to use is in EditProfileView
    @IBOutlet weak var dmButton: UIButton!
    @IBOutlet weak var ratingLeftLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet var outfitArrows: [UIButton]!
    @IBOutlet weak var submitOutfitButton: UIButton!
    @IBOutlet weak var businessProfileContainer: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Profile"
        ratingStars.settings.fillMode = .half
        SKPaymentQueue.default().add(self)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
        
        guard let _ = Auth.auth().currentUser?.uid else {//user signed out
            performSegue(withIdentifier: "ToMainStoryboard", sender: self)
            return
        }
        
        configureView()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    func setTextFields(){
        nameField.text = user.fullname!
    }
    
    func configureView(){
        if user.uid == Auth.auth().currentUser?.uid{//if current user
            user = MapViewController.currentUser
            setTextFields()
            let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.settingsTapped))
            self.navigationItem.setRightBarButton(settingsButton, animated: true)
            dmButton.isHidden = true
            dmButton.isEnabled = false
            submitOutfitButton.layer.cornerRadius = submitOutfitButton.frame.height/4
            handleBusinessProfileView()
            disableRating()
        } else {//not current user
            setTextFields()
            handleBusinessProfileView()
            self.allowRating()
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
    
    func configureBusinessLabels() {
        let ref = Database.database().reference()
        ref.child(FirebaseNodes.userBusiness).child(self.user.uid!).observe(.value) { (snapshot) in
            if let businessId = snapshot.value as? String {
                ProfileViewController.businessId = businessId
                ref.child(FirebaseNodes.businesses).child(businessId).observe(.value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String: Any] {
                        if let businessName = dict["name"] as? String{
                            self.businessNameLabel.text = businessName
                        }
                    }
                })
                ref.child(FirebaseNodes.businessStands).child(businessId).observe(.value, with: { (snapshot) in
                    let standsCount = String(snapshot.childrenCount)
                    self.standTotalLabel.text = standsCount
                })
            }
        }
    }
    
    func handleBusinessProfileView () {
        
        businessProfileContainer.backgroundColor = UIColor.lightGray
        businessProfileContainer.layer.cornerRadius = 6
        if (user.hasBusinessProfile!) {
            print("HAS BP")
            //  disable not creatBP label
            self.bpNotCreatedLabel.isHidden = true
            self.bpNotCreatedLabel.isEnabled = false
            //  disable createBP button
            self.createBPButton.isHidden = true
            self.createBPButton.isEnabled = false
            businessNameLabel.isHidden = false
            businessNameLabel.isEnabled = true
            businessNameLeftLabel.isHidden = false
            businessNameLeftLabel.isEnabled = true
            standTotalLabel.isHidden = false
            standTotalLabel.isEnabled = true
            standTotalLeftLabel.isHidden = false
            standTotalLeftLabel.isEnabled = true
            //  set text fields
            self.configureBusinessLabels()
        } else {// business not set up
        //  disable left labels
            businessNameLeftLabel.isHidden = true
            businessNameLeftLabel.isEnabled = false
            standTotalLeftLabel.isEnabled = false
            standTotalLeftLabel.isHidden = true
        // disable right labels
            businessNameLabel.isHidden = true
            businessNameLabel.isEnabled = false
            standTotalLabel.isEnabled = false
            standTotalLabel.isHidden = true
            //  enable not creatBP label
            self.bpNotCreatedLabel.isHidden = false
            self.bpNotCreatedLabel.isEnabled = true
            
            if (user.uid == Auth.auth().currentUser?.uid) {
                //  enable createBP button
                self.createBPButton.layer.cornerRadius = self.createBPButton.frame.height/4
                self.createBPButton.isHidden = false
                self.createBPButton.isEnabled = true
            }
        }
    }
    @IBAction func dmButtonPressed(_ sender: Any) {
        MessagesViewController.showChatController(otherUser: user, view: self)
    }
    @IBAction func createBPButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Create your business", message: "All we need is the business name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Business name..."
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            if !Connectivity.isConnectedToInternet{
                ProgressHUD.showError("Not connected to internet")
                return
            }
            
            let textField = alert?.textFields![0]
            self.isUniqueName(textField) { (bool) in
                if bool {
                    ProgressHUD.show()
                    self.saveBusiness(textField)
                } else {
                    ProgressHUD.showError("Unfortunately, this name has already been taken by another business.")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isUniqueName(_ textField: UITextField?, completion: @escaping (Bool)->()){
        
        Database.database().reference().child(FirebaseNodes.businessNames).observeSingleEvent(of: .value) { (snap) in
            if let dict = snap.value as? [String: Any] {
                for (name, _) in dict {
                    
                    if name == textField!.text{
                        completion(false)
                        return
                    }
                    
                }
                print("UNIQUE NAME")
                completion(true)
            } else {
                completion(true)
            }
        }
    }
    
    func saveBusiness(_ textField: UITextField?) {
        guard let newBusinessName = textField?.text! else {
            ProgressHUD.showError("Retype the name...")
            return
        }
        let userRef = Database.database().reference().child(FirebaseNodes.users).child(self.user.uid!)
        userRef.child(FirebaseNodes.hasBusinessProfile).setValue("1", withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Error creating your business... Try again.")
                return
            }
            let newBusinessId = userRef.child(FirebaseNodes.businessId).childByAutoId().key
            Database.database().reference().child(FirebaseNodes.userBusiness).child(self.user.uid!).setValue(newBusinessId!, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError("Error creating your business... Try again.")
                    return
                }
                let businessRef = Database.database().reference().child(FirebaseNodes.businesses).child(newBusinessId!)
                businessRef.setValue([FirebaseNodes.name: newBusinessName, FirebaseNodes.businessId: newBusinessId, FirebaseNodes.userID: self.user.uid!], withCompletionBlock: { (error, ref) in
                    Database.database().reference().child(FirebaseNodes.businessNames).child(newBusinessName).setValue(1, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            ProgressHUD.showError("Error creating your business... Try again.")
                            return
                        }
                        MapViewController.reloadCurrentUser(onSuccess: {
                            self.configureView()
                            ProgressHUD.showSuccess("Successfully created your business!!")
                        })
                    })
                })
            })
        })
    }
    
    @IBAction func saveOutfitPressed(_ sender: Any) {
        
        if !user.unlockedHats.contains(String(hatIndex)) || !user.unlockedShirts.contains(String(shirtIndex)) || !user.unlockedPants.contains(String(pantsIndex)){
            
            ProgressHUD.showError("You have not unlocked all of these clothes yet")
            return
        } else if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Check internet connection")
            return
        }
        
        let newAvatarValue = ["hatIndex": String(hatIndex), "shirtIndex": String(shirtIndex), "pantsIndex": String(pantsIndex)] 
        
        
        let ref = Database.database().reference().child(FirebaseNodes.users).child(Auth.auth().currentUser!.uid).child(FirebaseNodes.avatar)
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
        
        if !Connectivity.isConnectedToInternet{
            ProgressHUD.showError("Check internet connection")
            return
        }
        Database.database().reference().child(FirebaseNodes.userRated).child((Auth.auth().currentUser?.uid)!).child(user.uid!).setValue(1) { (error, ref) in
            let ref = Database.database().reference().child(FirebaseNodes.userRatings).child(self.user.uid!).childByAutoId()
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
        self.submitRatingButton.isHidden = true
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
            let label = UILabel(frame: self.ratingStars.frame)
            label.text = "Not Connected to Internet"
            label.textAlignment = .center
            label.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            self.bottomScrollView.addSubview(label)
            self.ratingStars.rating = 0.0
            return
        }
        Database.database().reference().child(FirebaseNodes.userRatings).child(user.uid!).observe(.value) { (snapshot) in
            
            if let snap = snapshot.value as? NSDictionary{
                
                var totalScore: Double = 0.0
                let numRatings = snap.count
                for (_, rating) in snap {
                    
                    if let dict = rating as? NSDictionary {
                        
                        totalScore += dict["score"] as! Double
                    }
                    
                }
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                self.ratingStars.rating = ( totalScore / Double(numRatings) )
                let rating = formatter.string(from: NSNumber(value: self.ratingStars!.rating))
                self.ratingLabel.text = rating!
                
            } else {
                self.ratingLabel.text = "NONE"
                self.ratingStars.rating = 0.00
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
        handleLeftArrow(index: &hatIndex, staticArray: ProfileViewController.hatNames)
        
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
                purchaseOutfit()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed{
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    ProgressHUD.showError("Failed: \(errorDescription)")
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
        let ref = Database.database().reference().child(FirebaseNodes.users).child(Auth.auth().currentUser!.uid).child(self.iapAvatarNodeToAdjust!)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            ref.child(String(snapshot.childrenCount)).setValue(String(self.indexToBuy!))
            MapViewController.reloadCurrentUser() {
                self.user = MapViewController.currentUser
                self.configureView()
            }
        }
    }
    
    static func logOutAndPresentSignUpView() {
        AuthService.logout(sender: nil)
    }
}
