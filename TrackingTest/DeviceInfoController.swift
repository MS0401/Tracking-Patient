//
//  DeviceInfoController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 09/01/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RSLoadingView
import CoreLocation

protocol UpdateGeotificationsViewControllerDelegate {
//    func updateGeotificationViewController(controller: DeviceInfoController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, removeCoordinate: CLLocationCoordinate2D, removeRadius: Double, removeIdentifer: String, removeNote: String)
    func updateGeotificationViewController(controller: DeviceInfoController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String)
    
    func removeGeotificationViewController(controller: DeviceInfoController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String)
}

class DeviceInfoController: UIViewController, UITextFieldDelegate {
    
    
    var delegate: UpdateGeotificationsViewControllerDelegate?
    var selectedGeotification: Geotifications!
    var viaDeviceList: Bool = false
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var photos: UIImageView!
    @IBOutlet var photoView: UIView!
    
    @IBOutlet var deviceName: UILabel!
    @IBOutlet var photoName: UILabel!
    @IBOutlet var nickName: UITextField!
    @IBOutlet var emergencyNumber: UILabel!
    @IBOutlet var batteryLevel: UITextField!
    
    let loadingView = RSLoadingView()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    var appDelegate: AppDelegate!
    
    var profile: Account = Account()
    var editDeviceInfo: DeviceInfo = DeviceInfo()
    @IBOutlet var locationUpdateFrequency: UITextField!
    @IBOutlet var geofenceParameter: UITextField!
    
    var selectedAccountImage: UIImage!
    var selectedAccountImageURL = ""
    var selectedEmergencyNumber = ""
    var selectedUserName = ""
    
    var items = [User]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
                
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EmergencyCallController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.Setup()
        self.DisplayDeviceInfo()
        if SharingManager.sharedInstance.selectedUser {
            self.photos.image = self.selectedAccountImage
            self.emergencyNumber.text = self.selectedEmergencyNumber
            self.emergencyNumber.textColor = UIColor.black
            
            self.deviceName.text = self.selectedUserName
            SharingManager.sharedInstance.selectedUser = false
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.ref.child("TrackingTest/\(self.editDeviceInfo.phoneNumber)/Profile").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            for item1 in snapshot.children {
                let child = item1 as! DataSnapshot
                let dict = child.value as! NSDictionary
                self.profile = Account(dictionary: dict)
            }
        })
        
    }
    
    
    func Setup() {
        
        self.topView.layer.shadowColor = UIColor.black.cgColor
        self.topView.layer.shadowOpacity = 0.7
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.topView.layer.shadowRadius = 3
         
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOpacity = 0.7
        self.bottomView.layer.shadowOffset = CGSize(width: 3.0, height: 0)
        self.bottomView.layer.shadowRadius = 3
        
        self.photos.layer.cornerRadius = self.photos.frame.size.height / 2
        self.photos.layer.masksToBounds = true
        
        self.emergencyNumber.layer.borderWidth = 1
        self.emergencyNumber.layer.borderColor = UIColor.black.cgColor
        
        self.photoView.layer.cornerRadius = 5
    }
    
    func DisplayDeviceInfo() {
        
        self.photos.image = self.editDeviceInfo.image
        self.deviceName.text = self.editDeviceInfo.name
        self.nickName.text = self.editDeviceInfo.name
        self.photoName.text = self.editDeviceInfo.name
        self.locationUpdateFrequency.text = self.editDeviceInfo.locationUpdateFrequency
        self.geofenceParameter.text = self.editDeviceInfo.geofenceParameter
        self.emergencyNumber.text = self.editDeviceInfo.phoneNumber
        self.batteryLevel.text = self.editDeviceInfo.batteryLevel
        
    }
    
    //Downloads users list for Contacts View
    func fetchUsers()  {
        if let id = Auth.auth().currentUser?.uid {
            User.downloadAllUsers(exceptID: id, completion: {(user) in
                self.items.append(user)
            })
        }
    }
    
    @IBAction func UpdateDeviceInfo(_ sender: UIButton) {
        
        self.loadingView.show(on: view)
        
        let alertController = UIAlertController(title: "Save!", message: "Do you really save this device?", preferredStyle: .alert)
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
        let emergencyNumber = self.emergencyNumber.text!
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
            
                //getting image URL from library or photoAlbum.
                var data: NSData = NSData()
                if let image = self.photos.image {
                    data = UIImageJPEGRepresentation(image, 0.1)! as NSData
                }
                let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                
                let dataInformation: NSDictionary = ["imageURL": imageURL, "nickName": nickName, "locationUpdateFrequency": locationUpdateFrequency, "geofenceParameter": geofenceParameter, "emergencyNumber": emergencyNumber, "batteryLevel": batteryLevel]
                
                //MARK: add firebase child node
                let child1 = ["/TrackingTest/\(path)/DeviceList/\(emergencyNumber)/": dataInformation]
                
                //MARK: Write data to Firebase
                self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        
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
                            
                            self.delegate?.updateGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note)
                            
                            let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
                            
                            if self.viaDeviceList {
                                print("it camed via DeviceList Controller.")
                                self.viaDeviceList = false
                            }else {
                                (vc as! MapViewController).backFromHistory = true
                            }
                            
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
    
    @IBAction func SelectEmergencyNumber(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    @IBAction func GotoMapViewController(_ sender: UIButton) {
          
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
        
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @IBAction func GotoHistoryController(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "history", sender: self)
        
    }
    
    @IBAction func GotoChat(_ sender: UIButton) {
        
        if self.items.count != 0 {
            
            for item in 0 ..< self.items.count {
                
                if self.items[item].email == self.profile.userEmail {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
                    vc.selectedUserIndex = item
                    vc.items = self.items
                    
                    self.show(vc, sender: nil)
                    self.loadingView.hide()
                    
                }
            }
        }else {
            showAlert("Warning!", message: "View is still loading now. Excuse me, Would you please wait for a minute?")
        }
       
    }
    
    @IBAction func GotoHealthController(_ sender: UIButton) {
    }
    
    
    //MARK: Calls this function when the tap is recorgnized
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "edit" {
            //self.progressBarDisplayer(msg: "Loading...", true)
            let deviceInfo = segue.destination as! AllDevicesController
            deviceInfo.edit = true
        }else if segue.identifier == "history" {
            
            let history = segue.destination as! HistoryViewController
            history.historyPath = self.emergencyNumber.text!
            history.selectDeviceName = self.nickName.text!
            history.selectPhotoName = self.nickName.text!
            history.selectedPhoto = self.photos.image!
            history.historydeviceinfo = true
        }
        
//        }else if segue.identifier == "navChat" {
//            
//            self.loadingView.show(on: view)
//            print("self.items(deviceInfo) count is \(self.items.count)")
//            
//            self.ref.child("TrackingTest/\(self.editDeviceInfo.phoneNumber)/Profile").observeSingleEvent(of: DataEventType.value, with: { snapshot in
//                for item1 in snapshot.children {
//                    let child = item1 as! DataSnapshot
//                    let dict = child.value as! NSDictionary
//                    
//                    self.profile = Account(dictionary: dict)
//                    
//                }
//                
//                print("self.items(deviceInfo) count is \(self.items.count)")
//                for item in 0 ..< self.items.count {
//                    //                    if self.items[item].email == self.profile.userEmail {
//                    //                        SharingManager.sharedInstance.chatUserIndex = item
//                    //
//                    //                        _ = segue.destination as! NavVC
//                    //                        break
//                    //
//                    //                    }
//                    if self.items[item].email == "fordevelop0401@yandex.com" {// self.profile.userEmail
//                        
//                        let vc = segue.destination as! NavVC
//                        vc.selectedUserIndex = item
//                        vc.items = self.items
//                        
//                        self.loadingView.hide()
//                        
//                    }
//                }
//                
//            })
//        }
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
