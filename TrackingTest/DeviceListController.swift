//
//  DeviceListController.swift
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

protocol DeviceListGeotificationsViewControllerDelegate {
    
    func removeFromDeviceListGeotificationViewController(controller: DeviceListController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String)
}

class DeviceListController: UIViewController {
    
    var delegate: DeviceListGeotificationsViewControllerDelegate?
    var deviceGeotifyArray: [Geotifications] = [Geotifications]()
    
    var appDelegate: AppDelegate!
    
    //MARK: outlet property
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var myImage: UIImageView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var ref: DatabaseReference!
    
    var DeviceInfos: [DeviceInfo] = [DeviceInfo]()
    var SelectedDevice: DeviceInfo = DeviceInfo()
    
    let loadingView = RSLoadingView()
    let path = SharingManager.sharedInstance.phoneNumber

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
                
        self.ref = Database.database().reference()
        self.Setup()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.DeviceInfos.removeAll()
        self.deviceGeotifyArray.removeAll()
        self.DownloadDeviceGeotificationArray()
    }
    
    func DownloadingDeviceList() {
            
            //MARK: History downloading from Firebase
            self.ref.child("TrackingTest/\(self.path)/DeviceList").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                
                for item in snapshot.children {
                    
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let deviceInfo = DeviceInfo(dictionary: dict)
                    
                    self.DeviceInfos.append(deviceInfo)                    
                    
                }
                
                if self.DeviceInfos.count == 0 {
                    print("No Device")
                    self.loadingView.hide()
                }else {
                    self.tableView.reloadData()
                    self.loadingView.hide()
                }
                
            })
    }
    
    func DownloadDeviceGeotificationArray() {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.loadingView.show(on: self.view)
            
            let path = SharingManager.sharedInstance.phoneNumber
            
            var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
            
            self.ref.child("TrackingTest/\(path)/Geotifications").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                
                for item1 in snapshot.children {
                    
                    let child = item1 as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    let tempString = dict["coordinate"] as! String
                    let coordinateString = tempString.components(separatedBy: ", ")
                    coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
                    
                    let note = dict["note"] as! String
                    let identifier = dict["identifier"] as! String
                    let radiusString = dict["radius"] as! String
                    let radius = Double(radiusString)!
                    
                    let geotification = Geotifications.init(coordinate: coordinate, radius: radius, identifier: identifier, note: note)
                    
                    self.deviceGeotifyArray.append(geotification)
                    
                }
                
                if self.deviceGeotifyArray.count == 0 {
                    
                    self.loadingView.hide()
                }else {
                    self.DownloadingDeviceList()
                }
                
                
            })
            
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func Setup() {
        
        //MARK: topView and BottomView customize(borderwidth, borderColor, shadow effect)
        self.topView.layer.shadowColor = UIColor.black.cgColor
        self.topView.layer.shadowOpacity = 0.7
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.topView.layer.shadowRadius = 3
           
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOpacity = 0.7
        self.bottomView.layer.shadowOffset = CGSize(width: 3.0, height: 0)
        self.bottomView.layer.shadowRadius = 3
        
        self.myImage.layer.cornerRadius = self.myImage.frame.size.width/2
        self.myImage.layer.masksToBounds = true
        
        self.photoView.layer.cornerRadius = 5
    }
    
    
    @IBAction func GotoSMSVc(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "sms", sender: self)
        
    }
    
    
    @IBAction func GotoMain(_ sender: UIButton) {
        
        
        
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
//        (vc as! MapViewController).backFromHistory = true
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "deviceEdit" {
            //self.progressBarDisplayer(msg: "Loading...", true)
            let deviceInfo = segue.destination as! DeviceInfoController
            deviceInfo.editDeviceInfo = self.SelectedDevice
            
            if self.deviceGeotifyArray.count != 0 {
                for geotify in self.deviceGeotifyArray {
                    if "You are near \(deviceInfo.editDeviceInfo.name)" == geotify.note {
                        deviceInfo.selectedGeotification = geotify
                    }
                }
            }            
            deviceInfo.viaDeviceList = true
            deviceInfo.delegate = SharingManager.sharedInstance.MapViewVC
        }else if segue.identifier == "sms" {
            let smsVC = segue.destination as! SMSViewController
            smsVC.deviceArray = self.DeviceInfos
            smsVC.deviceList = self
        }
        
    }
}

extension DeviceListController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.DeviceInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath) as! DeviceCell
        
        var deviceList: DeviceInfo = DeviceInfo()
        deviceList = self.DeviceInfos[indexPath.row]
        
        cell.deviceImage.image = deviceList.image
        self.CircleImage(profileImage: cell.deviceImage!)
        cell.deviceName.text! = deviceList.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var deviceList: DeviceInfo = DeviceInfo()
        deviceList = self.DeviceInfos[indexPath.row]
        self.SelectedDevice = deviceList
        self.performSegue(withIdentifier: "deviceEdit", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "REALLY?", message: "Do you really want to remove this device?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
            
                self.loadingView.show(on: self.view)
                
                var deviceItem: DeviceInfo = DeviceInfo()
                deviceItem = self.DeviceInfos[indexPath.row]
                let selectPath = deviceItem.phoneNumber
                
                self.ref.child("TrackingTest/\(self.path)/DeviceList/\(selectPath)/").removeValue(completionBlock: { (error, ref) in
                    
                    if error == nil {
                        
                                                
                        // MARK: checking whether deviceList change or not.
                        SharingManager.sharedInstance.changeList = true
                        
                        let tempGeotify = self.deviceGeotifyArray[indexPath.row]
                        
                        let geotification = Geotifications(coordinate: tempGeotify.coordinate, radius: tempGeotify.radius, identifier: tempGeotify.identifier, note: tempGeotify.note)
                        
                        self.delegate?.removeFromDeviceListGeotificationViewController(controller: self, didAddCoordinate: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier, note: geotification.note)
                        
                        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
                        self.navigationController?.popToViewController(vc!, animated: true)
                        
                        self.loadingView.hide()
                        
                    }else {
                        self.loadingView.hide()
                        self.showAlert("Error", message: (error?.localizedDescription)!)
                    }
                    
                })
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
    }
    
}
