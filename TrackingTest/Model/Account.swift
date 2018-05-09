//
//  Account.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Account {
    
    var name: String
    var userEmail: String
    var userPassword: String
    var phoneNumber: String
    var image: UIImage
    var imgURL: String
    
    init() {
        
        self.name = ""
        self.userEmail = ""
        self.userPassword = ""
        self.phoneNumber = ""
        self.image = UIImage.init()
        self.imgURL = ""
    }
    
    init(name: String, useremail: String, userpassword: String, image: UIImage, imgURL: String, phonenumber: String) {
        
        self.name = name
        self.userEmail = useremail
        self.userPassword = userpassword
        self.phoneNumber = phonenumber
        self.image = image
        self.imgURL = imgURL
    }
    
    convenience init(dictionary: NSDictionary) {
        
        
        let name = dictionary["userName"] as! String
        let useremail = dictionary["userEmail"] as! String
        let userpassword = dictionary["userPassword"] as! String
        let phonenumber = dictionary["phoneNumber"] as! String
        let imageURL = dictionary["imageURL"] as! String
        
        //Convert from String into Image.
        let decodeData = NSData(base64Encoded: imageURL, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let image = UIImage(data: decodeData! as Data, scale: 1.0)
        
        self.init(name: name, useremail: useremail, userpassword: userpassword, image: image!, imgURL: imageURL, phonenumber: phonenumber)
    }
    
}
