//
//  AllDevicesController.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RSLoadingView

class AllDevicesController: UIViewController {
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var photoName: UILabel!
    @IBOutlet var backBtn: UIButton!
    
    var ref: DatabaseReference!
    
    var accounts: [Account] = [Account]()
    
    var selectedUserImage: UIImage!
    var selectedUserImageURL = ""
    var selectedUserPhoneNumber = ""
    var selectedUserName = ""
    
    //MARK: RSLoadingView property
    let loadingView = RSLoadingView()
    
    var register: Bool = false
    var edit: Bool = false
    
    var dictArray: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Firebase reference path
        self.ref = Database.database().reference()
        
        self.Setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadingView.show(on: view)
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            //MARK: History downloading from Firebase
            self.ref.child("TrackingTest/Users").observe(DataEventType.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let phonenumber = dict["phoneNumber"] as! String
                    self.dictArray.append(phonenumber)
                    
                }
                
                if self.dictArray.count == 0 {
                    print("No history")
                    self.loadingView.hide()
                }else {
                    //MARK: downloading all users account data from users phoneNumber
                    self.DownloadingAllUsers()
                }
            })
        })
    }
    
    //MARK: Downloadinding All Users account data.
    func DownloadingAllUsers() {
        
        for item in self.dictArray {
            
            self.ref.child("TrackingTest/\(item)/Profile").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let profile = Account(dictionary: dict)
                    
                    if profile.phoneNumber != SharingManager.sharedInstance.phoneNumber {
                        
                        self.accounts.append(profile)
                    }
                    
                }
                
                if self.accounts.count == 0 {
                    print("No history")
                }else {
                    self.tableView.reloadData()
                }
                
                self.loadingView.hide()
                
            })
         }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func Setup() {
        
//        self.selectBtn.layer.cornerRadius = self.selectBtn.frame.size.height/2
//        self.selectBtn.layer.masksToBounds = true
//        
//        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
//        self.backBtn.layer.masksToBounds = true
        
        self.photo.layer.cornerRadius = self.photo.frame.size.width/2
        self.photo.layer.masksToBounds = true
        
        self.photoView.layer.cornerRadius = 5
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    @IBAction func BackToRegisterDeviceController(_ sender: UIButton) {
        
        if self.register {
            let  vc =  self.navigationController?.viewControllers.filter({$0 is RegisterDeviceController}).first
            self.navigationController?.popToViewController(vc!, animated: true)
        }else if self.edit {
            let  vc =  self.navigationController?.viewControllers.filter({$0 is DeviceInfoController}).first
            self.navigationController?.popToViewController(vc!, animated: true)
        }
        
    }
    
    
    @IBAction func SelectUserDevice(_ sender: UIButton) {
        
        if self.selectedUserPhoneNumber == "" || self.selectedUserName == "" {
            self.showAlert("Warning!", message: "You didn't select device. Please select your favorite device.")
        }else {
            if self.edit {
                SharingManager.sharedInstance.selectedUser = true
                
                let  vc =  self.navigationController?.viewControllers.filter({$0 is DeviceInfoController}).first
                
                (vc as! DeviceInfoController).selectedAccountImage = self.selectedUserImage
                (vc as! DeviceInfoController).selectedAccountImageURL = self.selectedUserImageURL
                (vc as! DeviceInfoController).selectedEmergencyNumber = self.selectedUserPhoneNumber
                (vc as! DeviceInfoController).selectedUserName = self.selectedUserName
                
                self.navigationController?.popToViewController(vc!, animated: true)
            }else if self.register {
                
                SharingManager.sharedInstance.selectedUser = true
                
                let  vc =  self.navigationController?.viewControllers.filter({$0 is RegisterDeviceController}).first
                
                (vc as! RegisterDeviceController).selectedAccountImage = self.selectedUserImage
                (vc as! RegisterDeviceController).selectedAccountImageURL = self.selectedUserImageURL
                (vc as! RegisterDeviceController).selectedEmergencyNumber = self.selectedUserPhoneNumber
                (vc as! RegisterDeviceController).selectedUserName = self.selectedUserName
                
                self.navigationController?.popToViewController(vc!, animated: true)
                
            }
        }
    }
    
    //MARK: show alert error message
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}

extension AllDevicesController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UITableViewDatasource method.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
        
        var profile: Account = Account()
        profile = self.accounts[indexPath.row]
        
        cell.accountImage.image = profile.image
        self.CircleImage(profileImage: cell.accountImage!)
        cell.userName.text! = profile.name
        
        return cell
    }
    
    //MARK: UITableViewDelegate method.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var profile: Account = Account()
        profile = self.accounts[indexPath.row]
        
        self.selectedUserImage = profile.image
        self.selectedUserPhoneNumber = profile.phoneNumber
        self.selectedUserImageURL = profile.imgURL
        self.selectedUserName = profile.name
        
        self.photo.image = profile.image
        self.photoName.text = profile.name
        
    }
    
}
