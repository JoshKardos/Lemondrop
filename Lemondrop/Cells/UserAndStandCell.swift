//
//  ListCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/4/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit

class UserAndStandCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var standsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configureCell(username: String, standsLabel: String){
        self.usernameLabel.text = username
        self.standsLabel.text = standsLabel
    }
}


