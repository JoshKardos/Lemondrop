//
//  EditProfileStandCell.swift
//  Lemondrop
//
//  Created by Josh Kardos on 10/20/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit

class EditProfileStandCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    func configureCell (stand : Stand) {
        nameLabel.text = stand.standName
        typeLabel.text = stand.type
//        imageView?.image = self.getStandImage(stand)
    }
    
//    func getStandImage (_ stand: Stand) -> UIImage{
//        if (stand.type == "pciture") {
//            return UIImage(named: "camera")!
//        } else {
//            return UIImage(named: "pencil")!
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
