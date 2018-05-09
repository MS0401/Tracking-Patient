//
//  AccountCell.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    @IBOutlet var accountImage: UIImageView!
    @IBOutlet var userName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
