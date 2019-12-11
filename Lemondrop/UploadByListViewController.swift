//
//  UploadByListViewController.swift
//  Lemondrop
//
//  Created by Josh Kardos on 12/11/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
import ProgressHUD
class UploadByListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    static var list = [Item]()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        nameTextField.returnKeyType = .done
        nameTextField.clearButtonMode = .always
        nameTextField.delegate = self
        
        priceTextField.addDoneButtonToKeyboard(myAction:  #selector(self.priceTextField.resignFirstResponder))
        priceTextField.delegate = self
        
        priceTextField.addTarget(self, action: #selector(priceTextFieldDidChange), for: .editingChanged)

    }
    
    @objc func priceTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        guard let name = nameTextField.text, var price = priceTextField.text else {
            ProgressHUD.showError("Both fields must contain text")
            return
        }
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines) == "" || price.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            ProgressHUD.showError("There should be more than just a space")
            return
        }
        
        price.removeFirst()
        price.removeAll(where: { (char) -> Bool in
            return char == ","
        })
        
        guard let priceDouble = Double(price) else {
            print(price)
            ProgressHUD.showError("Error with the item's price")
            return
        }
        
        let item = Item(name: name, price: priceDouble)
        UploadByListViewController.list.append(item)
        priceTextField.text = ""
        nameTextField.text = ""
        tableView.reloadData()
    }
}

extension UploadByListViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UploadByListViewController.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListCell
        cell.configureCell(item: UploadByListViewController.list[indexPath.row])
        return cell
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
}
