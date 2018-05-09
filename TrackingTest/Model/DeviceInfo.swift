//
//  DeviceInfo.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DeviceInfo {
    
    var name: String
    var locationUpdateFrequency: String
    var geofenceParameter: String
    var batteryLevel: String
    var phoneNumber: String
    var image: UIImage
    var imgURL: String
    
    init() {
        
        self.name = ""
        self.locationUpdateFrequency = ""
        self.geofenceParameter = ""
        self.batteryLevel = ""
        self.phoneNumber = ""
        self.image = UIImage.init()
        self.imgURL = ""
    }
    
    init(name: String, updateFrequency: String, geofenceParameter: String, batteryLevel: String, image: UIImage, imgURL: String, phonenumber: String) {
        
        self.name = name
        self.locationUpdateFrequency = updateFrequency
        self.geofenceParameter = geofenceParameter
        self.batteryLevel = batteryLevel
        self.phoneNumber = phonenumber
        self.image = image
        self.imgURL = imgURL
    }
    
    convenience init(dictionary: NSDictionary) {
        
        
        let name = dictionary["nickName"] as! String
        let LocationUpdateFrequency = dictionary["locationUpdateFrequency"] as! String
        let geoFenceParameter = dictionary["geofenceParameter"] as! String
        let BatteryLevel = dictionary["batteryLevel"] as! String
        let phonenumber = dictionary["emergencyNumber"] as! String
        let imageURL = dictionary["imageURL"] as! String
        
        //Convert from String into Image.
        let decodeData = NSData(base64Encoded: imageURL, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let image = UIImage(data: decodeData! as Data, scale: 1.0)
        
        self.init(name: name, updateFrequency: LocationUpdateFrequency, geofenceParameter: geoFenceParameter, batteryLevel: BatteryLevel, image: image!, imgURL: imageURL, phonenumber: phonenumber)
    }
    
}
