//
//  History.swift
//  TrackingTest
//
//  Created by admin on 9/8/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class History {
    
    var address: String
    var latlng: String
    var time: String
    var currentDate: Int
    
    
    init() {
        
        self.address = ""
        self.latlng = ""
        self.time = ""
        self.currentDate = 0
    }
    
    init(Address: String, LatLng: String, Time: String, date: Int) {
        
        self.address = Address
        self.latlng = LatLng
        self.time = Time
        self.currentDate = date
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let address = dictionary["address"] as! String
        let latlng = dictionary["latlng"] as! String
        let time = dictionary["time"] as! String
        let date = dictionary["date"] as! Int
        
        self.init(Address: address, LatLng: latlng, Time: time, date: date)
    }
    
}
