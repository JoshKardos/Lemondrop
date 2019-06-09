//
//  UserCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/6/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var fullnameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(fullname: String){
        fullnameLabel.text = fullname
    }

}
