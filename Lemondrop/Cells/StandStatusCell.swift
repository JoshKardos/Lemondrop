//
//  Lemondrop
//
//  Created by Josh Kardos on 6/14/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit
import CoreLocation
import MarqueeLabel
class StandStatusCell: UITableViewCell{
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var standNameLabel: MarqueeLabel!
    @IBOutlet weak var openClosedImageView: UIImageView!
    
    let closedImage = UIImage(named: "close-button")
    let openImage = UIImage(named: "open-button")
    
    let dateFormatter = DateFormatter()
    func configureCell(stand: Stand){
        print("CONFIGURE STATUS")

        dateFormatter.dateFormat = "MMM dd, yyyy"
        standNameLabel.text = "Stand Name: \(stand.standName!)"
        typeLabel.text = "Type: \(stand.type!)"
        
        if openClosedImageView != nil  {
            if stand.isOpen() {
                openClosedImageView.image = openImage
            } else {
                openClosedImageView.image = closedImage
            }
        }
    }
}

class StandClosedCell: StandStatusCell {
    override func configureCell(stand: Stand){
        print("CONFIGURE CLOSED")
        super.configureCell(stand: stand)
    }
}
