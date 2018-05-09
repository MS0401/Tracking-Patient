//
//  LelfMenuViewCell.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/21/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit

class LelfMenuViewCell: UITableViewCell {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
