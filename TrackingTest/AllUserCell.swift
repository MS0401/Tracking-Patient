//
//  AllUserCell.swift
//  TrackingTest
//
//  Created by admin on 9/12/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class AllUserCell: UITableViewCell {
    
    @IBOutlet var accountImage: UIImageView!
    @IBOutlet var userName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
