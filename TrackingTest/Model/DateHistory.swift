//
//  DateHistory.swift
//  TrackingTest
//
//  Created by admin on 9/13/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DateHistory {
    
    var address: String
    var latlng: String
    var historyDate: Int
    var historyYMD: String
    
    
    
    init() {
        
        self.address = ""
        self.latlng = ""
        self.historyDate = 0
        self.historyYMD = ""
        
    }
    
    init(Address: String, LatLng: String, HistoryYMD: String, HistoryDate: Int) {
        
        self.address = Address
        self.latlng = LatLng
        self.historyYMD = HistoryYMD
        self.historyDate = HistoryDate
        
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let address = dictionary["address"] as! String
        let latlng = dictionary["latlng"] as! String
        let historyYMD = dictionary["uploadYMD"] as! String
        let historyDate = dictionary["date"] as! Int
        
        
        self.init(Address: address, LatLng: latlng, HistoryYMD: historyYMD, HistoryDate: historyDate)
    }
    
    
}
