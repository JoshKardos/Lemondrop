//
//  UserCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/6/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import FirebaseAuth
class UserCell: UITableViewCell {

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var airplaneImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: Message){
        
        fullnameLabel.text = MapViewController.uidUserMap[message.chatPartnerId()!]?.fullname
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a MMM dd, yyyy"
        let timestampDate = NSDate(timeIntervalSince1970: message.timestamp as! TimeInterval)
        
        dateLabel.text = dateFormatter.string(from: timestampDate as Date)
        
        //last sender was not current user
        if message.senderId != (Auth.auth().currentUser?.uid)!{
            self.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
            airplaneImage.isHidden = false
        } else {
            self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            airplaneImage.isHidden = true
        }
        
    }

}
