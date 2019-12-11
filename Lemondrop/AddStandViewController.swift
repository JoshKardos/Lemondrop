//
//  AddStandViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 12/10/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import ProgressHUD
class AddStandViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @IBOutlet weak var listUploadedImage: UIImageView!
    @IBOutlet weak var standNameTextField: UITextField!
    @IBOutlet weak var typePickerWheel: UIPickerView!
    @IBOutlet weak var uploadByPhotoButton: UIButton!
    @IBOutlet weak var uploadByListButton: UIButton!
    var imagePicker: UIImagePickerController!
    var selectedType = "Food"
    var typeData: [String] = ["Food", "Clothes", "Miscellaneous"]
    var localPhotoData: Data?

    override func viewDidLoad() {
        listUploadedImage.isHidden = true
        
        typePickerWheel.dataSource = self
        typePickerWheel.delegate = self
        typePickerWheel.layer.cornerRadius = 4
        
        standNameTextField.returnKeyType = .done
        standNameTextField.clearButtonMode = .always
        standNameTextField.delegate = self
        
        uploadByListButton.layer.cornerRadius = 4
        uploadByPhotoButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UploadByListViewController.list.count < 1 {
            uploadByListButton.layer.borderWidth = 0
        } else {
            uploadByListButton.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            uploadByListButton.layer.borderWidth = 4
        }
    }
    
    deinit {
        UploadByListViewController.list = []
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        
        let newStandRef = Database.database().reference().child(FirebaseNodes.stands).childByAutoId()
        let newStandRefId = newStandRef.key!
        let values = ["standId": newStandRefId,"standName": self.standNameTextField!.text!, "uid": (Auth.auth().currentUser?.uid)!, "type": selectedType, "latitude": MapViewController.currentLocation!.coordinate.latitude, "longitude": MapViewController.currentLocation!.coordinate.longitude] as [String : Any]
        let alert = UIAlertController(title: "How would you like to store your menu?", message: "Pick One", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Photo & List", comment: "Default action"), style: .default, handler: { _ in
            // add photo
            // add list
            alert.removeFromParent()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("List", comment: "Default action"), style: .default, handler: { _ in
            // if list > 0
            // let value =
            // values["menuFromList": value ]
            alert.removeFromParent()
        }))
        
        if let _ = localPhotoData {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Photo", comment: "Default action"), style: .default, handler: { _ in
    //            values["menuPhotoUrl": self.menuPhotoUrl]
                self.savePhoto(standRefId: newStandRefId, onSuccess: {
                    self.saveLemonadeStand(newStandRef: newStandRef, newStandRefId: newStandRefId, values: values, onSuccess: {
                        self.successSaving()
                    }, onError: {
                        self.failureSaving()
                    })
                }, onError: {
                    self.failureSaving()
                })
                alert.removeFromParent()
            }))
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("None", comment: "Default action"), style: .default, handler: { _ in
            self.saveLemonadeStand(newStandRef: newStandRef, newStandRefId: newStandRefId, values: values, onSuccess: {
                self.successSaving()
            }, onError: {
                self.failureSaving()
            })
            alert.removeFromParent()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func savePhoto(standRefId: String, onSuccess: @escaping() -> Void, onError: @escaping() -> Void) {

        ProgressHUD.show("Saving photo. This might take a while...")
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("NO UID")
            return
        }
        guard let _ = localPhotoData else {
            print("No photo selected")
            return
        }
        
        //save to storage
        savePhotoHelper(localData: localPhotoData!, standRefId: standRefId, userId: userId, onSuccess:{
            onSuccess()
        }, onError: {
            onError()
        })
        //get url
    }
    
    func savePhotoHelper(localData: Data, standRefId: String, userId: String, onSuccess: @escaping() -> Void, onError: @escaping() -> Void){
        
        let ref = Database.database().reference().child(FirebaseNodes.standMenus).child(standRefId).child(FirebaseNodes.photoMenu)
        
        let newPhotoKey = ref.childByAutoId().key!
        
        let storageRef = Storage.storage().reference(forURL: FirebaseNodes.storageRef).child(FirebaseNodes.photoMenu).child(standRefId).child(newPhotoKey)
        
        storageRef.putData(localData, metadata: nil) { (metadata, error) in
            if error != nil{
                onError()
                return
            }
            storageRef.downloadURL { (photoUrl, error) in
                if error != nil{
                    print("Error downloading URL: \(error!.localizedDescription)")
                    onError()
                    return
                }
                guard let url = photoUrl?.absoluteString else{
                    print("no url")
                    onError()
                    return
                }
                ref.updateChildValues(["photoId": newPhotoKey, "url" : url, "uid": userId])
                onSuccess()
                return
            }
        }
    }
    
    func failureSaving() {
        ProgressHUD.showError("Failure saving to our records...")
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func successSaving() {
        ProgressHUD.showSuccess("Success!")
        self.navigationController?.popViewController(animated: true)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if  let image = info[.originalImage] as? UIImage, let photoData = image.pngData() {
            localPhotoData = photoData
            uploadByPhotoButton.setImage(image, for: .normal)
        } else{
            ProgressHUD.showError("Error selecting video... Please try again.")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadByPhotoPressed(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadByListPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToUploadMenuByList", sender: nil)
    }
    
    func saveLemonadeStand(newStandRef: DatabaseReference, newStandRefId: String, values: [String: Any], onSuccess: @escaping() -> Void, onError: @escaping() -> Void){
        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            newStandRef.setValue(values){ (error, ref) in
                if error != nil{
                    onError()
                } else {
                    Database.database().reference().child(FirebaseNodes.businessStands).child(MapViewController.currentUsersBusiness!.businessId!).child(newStandRefId).setValue(1) { (error, ref) in
                        if error != nil {
                            onError()
                        } else {
                            onSuccess()
                        }
                    }
                }
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

extension AddStandViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.typeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.typeData[row]
    }
    
    ///
    /// Remove keyboard on done pressed and when background is touched
    ///
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedType = typeData[row]
    }
}
