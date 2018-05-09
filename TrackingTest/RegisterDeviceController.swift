//
//  RegisterDeviceController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 09/01/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RSLoadingView
import CoreLocation

protocol AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: RegisterDeviceController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String)
}

class RegisterDeviceController: UIViewController, UITextFieldDelegate {
    
    
    var appDelegate: AppDelegate!
    
    
    //MARK: outlet property
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var photos: UIImageView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var registerName: UILabel!
    
    @IBOutlet var nickName: UITextField!
    @IBOutlet var locationUpdateFrequency: UITextField!
    @IBOutlet var geofenceParameter: UITextField!
    @IBOutlet var emergencyNumber: UILabel!
    @IBOutlet var batteryLevel: UITextField!
    
    // Loading View property
    let loadingView = RSLoadingView()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    var selectedAccountImage: UIImage!
    var selectedAccountImageURL = ""
    var selectedEmergencyNumber = ""
    var selectedUserName = ""
    
    var delegate: AddGeotificationsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EmergencyCallController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.Setup()
        
        if SharingManager.sharedInstance.selectedUser {
            self.photos.image = self.selectedAccountImage
            self.emergencyNumber.text = self.selectedEmergencyNumber
            self.emergencyNumber.textColor = UIColor.black
            
            self.registerName.text = self.selectedUserName
            SharingManager.sharedInstance.selectedUser = false
        }        
    }
    
    func Setup() {
        
        //MARK: topView and BottomView customize(shadow effect)
        //MARK: topView and BottomView customize(borderwidth, borderColor, shadow effect)
        self.topView.layer.shadowColor = UIColor.black.cgColor
        self.topView.layer.shadowOpacity = 0.7
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.topView.layer.shadowRadius = 3
        
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOpacity = 0.7
        self.bottomView.layer.shadowOffset = CGSize(width: 3.0, height: 0)
        self.bottomView.layer.shadowRadius = 3
        
        self.emergencyNumber.layer.borderWidth = 1
        self.emergencyNumber.layer.borderColor = UIColor.black.cgColor
        
        //MARK: photo corner Radius
        self.photos.layer.cornerRadius = self.photos.frame.size.width/2
        self.photos.layer.masksToBounds = true
        
        self.photoView.layer.cornerRadius = 5
        
        self.photos.image = UIImage(named: "setting_image.png")
        self.registerName.text = "photos"
    }
    @IBAction func GotoMapViewController(_ sender: UIButton) {
        
        SharingManager.sharedInstance.backInMain = true
        
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
//        (vc as! MapViewController).backFromHistory = true
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @IBAction func SelectEmergencyNumber(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    
    @IBAction func RegisterNewDevice(_ sender: UIButton) {
        
        self.loadingView.show(on: view)
        
        let alertController = UIAlertController(title: "Register!", message: "Do you really register this device?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            
            self.Uploading()            
        }
        let cancel = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
            self.loadingView.hide()
        }
        
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //MARK: Firebase uploading function/// ******** important ********
        
        let path = SharingManager.sharedInstance.phoneNumber
        
        let nickName = self.nickName.text!
        let locationUpdateFrequency = self.locationUpdateFrequency.text!
        let geofenceParameter = self.geofenceParameter.text!
        let emergencyNumber = self.selectedEmergencyNumber
        let batteryLevel = self.batteryLevel.text!
        if self.nickName.text == "" {
            self.loadingView.hide()
            self.showAlert("Warning!", message: "You didn't input NickName. Please input your device's NicName.")
        }else if self.locationUpdateFrequency.text == "" {
            self.loadingView.hide()
            self.showAlert("Warning!", message: "You didn't input Location update time interval. Please input location update time interval.")
        }else if self.geofenceParameter.text == "" {
            self.loadingView.hide()
            self.showAlert("Warning!", message: "You didn't input geofence parameter. Please input geofence parameter.")
        }else if self.emergencyNumber.text == "Select phone number" {
            self.loadingView.hide()
            self.showAlert("Warning!", message: "You didn't select emergency phone number. Please input emergency phone number.")
        }else if self.batteryLevel.text == "" {
            self.loadingView.hide()
            self.showAlert("Warning!", message: "You didn't input battery level. Please input battery level")
        }else {
            
            DispatchQueue.main.async(execute: { () -> Void in
            
                let imageURL = self.selectedAccountImageURL
                let dataInformation: NSDictionary = ["imageURL": imageURL, "nickName": nickName, "locationUpdateFrequency": locationUpdateFrequency, "geofenceParameter": geofenceParameter, "emergencyNumber": emergencyNumber, "batteryLevel": batteryLevel]
                
                //MARK: add firebase child node
                let child1 = ["/TrackingTest/\(path)/DeviceList/\(emergencyNumber)/": dataInformation]
                
                //MARK: Write data to Firebase
                self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        
                        // MARK: checking whether deviceList change or not.
                        SharingManager.sharedInstance.changeList = true
                        
                        //MARK: add Geofencing parameter.
                        self.ref.child("TrackingTest/\(emergencyNumber)/CurrentLocation").observeSingleEvent(of: DataEventType.value, with: { snapshots in
                            
                            var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
                            
                            for item2 in snapshots.children {
                                let child1 = item2 as! DataSnapshot
                                let dict1 = child1.value as! NSDictionary
                                print("dict is \(dict1)")
                                let updatedLocationString = dict1["currentLocation"] as! String
                                
                                let coordinateString = updatedLocationString.components(separatedBy: ", ")
                                coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
                                
                            }
                            
                            //MARK: ADD Geofencing item.
                            let radius = Double(self.geofenceParameter.text!) ?? 0
                            let identifier = NSUUID().uuidString
                            let note = "You are near \(self.nickName.text!)"
                                                        
                            self.delegate?.addGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note)
                            
                            let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
                            self.navigationController?.popToViewController(vc!, animated: true)
                            
                            self.loadingView.hide()
                            
                        })
                    }else {
                        self.loadingView.hide()
                        self.showAlert("Error!", message: (error?.localizedDescription)!)
                    }
                })
            })
        }
        
    }
    
    //MARK: show alert error message
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: Calls this function when the tap is recorgnized
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "register" {
            //self.progressBarDisplayer(msg: "Loading...", true)
            let deviceInfo = segue.destination as! AllDevicesController
            deviceInfo.register = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
