//
//  DeviceCell.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    
    @IBOutlet var deviceName: UILabel!
    @IBOutlet var deviceImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
