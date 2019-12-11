//
//  ListCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 12/11/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import Foundation
import UIKit
class ListCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configureCell(item: Item) {
        nameLabel.text = item.name
        priceLabel.text = String(item.price)
    }
    
}
