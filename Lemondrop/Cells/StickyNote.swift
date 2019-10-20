//
//  StickyNote.swift
//  Lemondrop
//
//  Created by Josh Kardos on 6/18/19.
//  Copyright © 2019 Josh Kardos. All rights reserved.
//

import UIKit

class StickyNote: UICollectionViewCell {
    @IBOutlet weak var standNameLabel: UILabel!
    
    @IBOutlet weak var closingTimeLabel: UILabel!
    @IBOutlet weak var byUsernameLabel: UILabel!
    
    func configureCell(stand: Stand){
        
        standNameLabel.text = stand.standName
        byUsernameLabel.text = "By: \(stand.creatorName!)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let timestampDate = NSDate(timeIntervalSince1970: stand.endTime)
        
        closingTimeLabel.text = "closes at: \(dateFormatter.string(from: timestampDate as Date))"
        
        
    }
    
}
