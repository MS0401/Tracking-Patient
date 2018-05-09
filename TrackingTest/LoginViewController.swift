//
//  LoginViewController.swift
//  TrackingTest
//
//  Created by admin on 9/6/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RSLoadingView
import CoreLocation

class LoginViewController: UIViewController {
    
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    var dictArray: [NSDictionary] = [NSDictionary]()
    
    //MARK: RSLoadingView property
    let loadingView = RSLoadingView()
    
    var userPhoneNumber = ""
    
    //MARK: Location Manager - CoreLocation Framework.
    var locationManager = CLLocationManager()
    
    //MARK: Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    //MARK: first sharing current location
    var firstShared: Bool = true
    
    var appDelegate: AppDelegate!
    
    //MARK: BackgroundTaskIdentifier for backgrond update location
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    var backgroundTaskIdentifier2: UIBackgroundTaskIdentifier!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: keeping inputed user's email
        self.retrieveAccountInfo()
        
        //MARK: Authorization for utilization of location services for background process
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            // Location Manager configuration
            locationManager.delegate = self
            
            // Location Accuracy, properties
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
            
        }
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    //Keep inputed email
    func retrieveAccountInfo() {
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "email") != nil {
            
            self.email.text = defaults.string(forKey: "email")
            self.password.text = defaults.string(forKey: "password")
            
        }        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        
        let email = self.email.text!
        let password = self.password.text!
        
        
        let defaults = UserDefaults.standard
        
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        
        
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
            
            self.loadingView.show(on: view)
            
            self.FirebaseEmailLogin()
        }
        
    }
    
    func FirebaseEmailLogin() {
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            
            if error == nil {
                
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                
                //MARK: History downloading from Firebase
                self.ref.child("TrackingTest/Users").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let dict = child.value as! NSDictionary
                        print(dict)
                        self.dictArray.append(dict)
                        
                    }
                    
                    if self.dictArray.count == 0 {
                        
                        self.showAlert("Warning!", message: "Have you ever logged in?. Please sign up!")
                    }else {
                        
                        for item in self.dictArray {
                            
                            let tempEmail = item["email"] as! String
                            if tempEmail == self.email.text! {
                                
                                self.userPhoneNumber = item["phoneNumber"] as! String
                                SharingManager.sharedInstance.phoneNumber = self.userPhoneNumber
                                
                                //MARK: Go to the VerificationViewController
                                let Root = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! NVController
                                self.present(Root, animated: true, completion: nil)
                                
                                self.loadingView.hide()
                            }
                        }
                    }
                    
                })
            } else {
                
                //Tells the user that there is an error and then gets firebase to tell them the error
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                self.loadingView.hide()
            }
        }
    }
    
    @IBAction func ForgotPasswordAction(_ sender: UIButton) {
        
        let forgot = self.storyboard?.instantiateViewController(withIdentifier: "forgot") as! ForgotPasswordViewController
        self.present(forgot, animated: true, completion: nil)
        
    }
    
    @IBAction func RegisterAction(_ sender: UIButton) {
        
        let register = self.storyboard?.instantiateViewController(withIdentifier: "temp") as! SignUpViewController
        self.present(register, animated: true, completion: nil)
        
    }
    
    @IBAction func BackVerificationViewController(_ sender: UIButton) {
        
        let backVerification = self.storyboard?.instantiateViewController(withIdentifier: "verification") as! VerificationViewController
        self.present(backVerification, animated: true, completion: nil)
    }
    
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LoginViewController:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        SharingManager.sharedInstance.currentLoc = locValue
        SharingManager.sharedInstance.currentLocation = "\(locValue.latitude), \(locValue.longitude)"
        
        if firstShared {
            SharingManager.sharedInstance.uploadingLoc = locValue
            SharingManager.sharedInstance.uploadingLocation = "\(locValue.latitude), \(locValue.longitude)"
            firstShared = false
        }
        
    }
}
