//
//  CustomToolBar.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/18/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
//This viewcontroller customize toolBar in everything viewcontroller.
class CustomToolBar: UIToolbar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 60  // there to set your toolbar height
        
        return newSize
    }
}
