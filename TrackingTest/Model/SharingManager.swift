//
//  SharingManager.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/09/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class SharingManager {
    
    static let sharedInstance = SharingManager()
    
    //Current location
    var currentLocation = ""
    var currentLoc: CLLocationCoordinate2D!
    
    //Destination location
    var destinationLocation = ""
    var destinationLoc: CLLocationCoordinate2D!
    
    //Uploading location
    var uploadingLocation = ""
    var uploadingLoc: CLLocationCoordinate2D!
    
    //clicking history tableview item
    var historyBool: Bool = false
    
    var selectDict: History = History()
    
    // User account information.
    
    // profile Image
    var profileImage: UIImage = UIImage()
    // User name
    var userName = ""
    // User email
    var userEmail = ""
    // User password
    var userPassword = ""
    // User age
    var userAge = ""
    
    // Signup successfull
    var signupSuccess: Bool = false
    
    // Current User phone number
    var phoneNumber = ""
    
    // Select device account from All users.
    var selectedUser: Bool = false
    
    //MARK: checking device uploading true or false.
    var uploadingDevice: Bool = false
    
    //MARK: checking whether app is first started, or not.
    var firstStart: Bool = false
    
    //MARK: checking whether deviceList change or not.
    var changeList: Bool = false
    
    //MARK: checking whether "Home" button click or not.
    var backInMain: Bool = false
    
    var MapViewVC: MapViewController = MapViewController()
    
}
