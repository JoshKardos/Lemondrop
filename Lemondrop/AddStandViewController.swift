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
    
    @IBAction func cancelPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        saveLemonadeStand()
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
        imagePicker.dismiss(animated: true, completion: nil)
        uploadByPhotoButton.setImage(info[.originalImage] as? UIImage, for: .normal)
    }
    
    @IBAction func uploadByPhotoPressed(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadByListPressed(_ sender: Any) {
        
    }
    
    func saveLemonadeStand(){
        
        let newStandRef = Database.database().reference().child(FirebaseNodes.stands).childByAutoId()
        let newStandRefId = newStandRef.key

        if Connectivity.isConnectedToInternet {
            ProgressHUD.show("Saving...")
            UIApplication.shared.beginIgnoringInteractionEvents()
            newStandRef.setValue(["standId": newStandRefId!,"standName": self.standNameTextField!.text!, "uid": (Auth.auth().currentUser?.uid)!, "type": selectedType, "latitude": MapViewController.currentLocation!.coordinate.latitude, "longitude": MapViewController.currentLocation!.coordinate.longitude]){ (error, ref) in
                if error != nil{
                    self.failureSaving()
                } else {
                    Database.database().reference().child(FirebaseNodes.businessStands).child(MapViewController.currentUsersBusiness!.businessId!).child(newStandRefId!).setValue(1) { (error, ref) in
                        if error != nil {
                            self.failureSaving()
                        } else {
                            self.successSaving()
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
