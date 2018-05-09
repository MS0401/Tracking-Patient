//
//  SMSViewController.swift
//  TrackingTest
//
//  Created by admin on 9/12/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RSLoadingView
import AAViewAnimator
import MessageUI

class SMSViewController: UIViewController, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var photo: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var photoName: UILabel!
    @IBOutlet var dropDown1: UIView!
    
    
    var ref: DatabaseReference!
    
    var accounts: [Account] = [Account]()
    var deviceArray: [DeviceInfo] = [DeviceInfo]()
    
    var selectedUserImage: UIImage!
    var selectedUserImageURL = ""
    var selectedUserPhoneNumber = ""
    var selectedUserName = ""
    
    //MARK: RSLoadingView property
    let loadingView = RSLoadingView()
    
    var register: Bool = false
    var edit: Bool = false
    var dropDown: Bool = true
    
    var dictArray: [String] = [String]()
    
    var deviceList = DeviceListController()
    
    var time: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Firebase reference path
        self.ref = Database.database().reference()
        
        self.Setup()
        
        self.loadingView.show(on: view)
        
        self.time = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SMSViewController.GotoRegisterController), userInfo: nil, repeats: true)
            
        self.accounts.removeAll()
        DispatchQueue.main.async(execute: { () -> Void in
          
            //MARK: History downloading from Firebase
            self.ref.child("TrackingTest/Users").observe(DataEventType.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let phonenumber = dict["phoneNumber"] as! String
                    self.dictArray.append(phonenumber)
                    
                }
                
                print("DictArray is \(self.dictArray)")
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
    
    func GotoRegisterController() {
        
        if register {
            register = false
            self.performSegue(withIdentifier: "register", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    //MARK: Downloadinding All Users account data.
    func DownloadingAllUsers() {
        
        var index = 0
        for item in self.dictArray {
            
            self.ref.child("TrackingTest/\(item)/Profile").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let profile = Account(dictionary: dict)
                    
//                    if profile.phoneNumber != SharingManager.sharedInstance.phoneNumber {
//                        
//                        self.accounts.append(profile)
//                        
//                    }   
                    self.accounts.append(profile)
                    
                    index = index + 1
                }
                
                if self.accounts.count == 0 {
                    print("No history")
                }else {
                    self.tableView.reloadData()
                }
                if index == self.dictArray.count {
                    self.loadingView.hide()
                }
                
                
            })
        }
        
    }
    
    func Setup() {
        
        self.photo.layer.cornerRadius = self.photo.frame.size.width/2
        self.photo.layer.masksToBounds = true
        
        self.photoView.layer.cornerRadius = 5
        
        self.dropDown1.layer.cornerRadius = 5
        self.dropDown1.layer.masksToBounds = true
        
        self.dropDown1.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SMSViewController.DismissDropDownView(sender:)))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
        self.tableView.isUserInteractionEnabled = true
        
    }
    
    func DismissDropDownView(sender: UITapGestureRecognizer) {
        
        if self.dropDown == false {
            
            self.animateWithTransition1(.toRight)
            
        }
    }
    
    //MARK: Very Important(UIGestureRecoginzerDelegate method) - UITapGestureRecognizer breaks UITableView didSelectRowAtIndexPath
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: self.tableView)
            return (tableView.indexPathForRow(at: location) == nil)
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GotoMain(_ sender: UIButton) {
        
        SharingManager.sharedInstance.backInMain = true
        
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @IBAction func ViaSMSandRegister() {
        
        if self.selectedUserPhoneNumber != "" && self.selectedUserName != "" && self.selectedUserImageURL != "" && self.selectedUserImage != nil {
            
            self.dropDown1.isHidden = false
            
            self.animateWithTransition1(.fromLeft)
            
        }else {
            self.showAlert("Warning!", message: "You didn't select device. Please select your favorite device.")
        }
    }
    
    @IBAction func SendSMSMessage(_ sender: UIButton) {
        
        self.animateWithTransition1(.toRight)
        
        self.loadingView.show(on: view)
        
        var selectBool: Bool = false
        
        if self.deviceArray.count == 0 {
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                let messageVC = MFMessageComposeViewController()
                
                messageVC.body = "Please login to monitor your loved one";
                messageVC.recipients = [self.selectedUserPhoneNumber]
                messageVC.messageComposeDelegate = self;
                
                self.present(messageVC, animated: false, completion: nil)
                
                self.loadingView.hide()
            })
        }else {
            
            for item in self.deviceArray {
                if item.phoneNumber != self.selectedUserPhoneNumber {
                    selectBool = true
                    continue
                }else {
                    self.loadingView.hide()
                    self.showAlert("Warning!", message: "You have already registered this device. Please select other device.")
                    selectBool = false
                    break
                }
            }
            
            if selectBool == true {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let messageVC = MFMessageComposeViewController()
                    
                    messageVC.body = "Please login to monitor your loved one";
                    messageVC.recipients = [self.selectedUserPhoneNumber]
                    messageVC.messageComposeDelegate = self;
                    
                    self.present(messageVC, animated: false, completion: nil)
                    
                    self.loadingView.hide()
                })
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "register" {
            
            SharingManager.sharedInstance.selectedUser = true
            
            let newDevice = segue.destination as! RegisterDeviceController
            newDevice.selectedAccountImage = self.selectedUserImage
            newDevice.selectedAccountImageURL = self.selectedUserImageURL
            newDevice.selectedEmergencyNumber = self.selectedUserPhoneNumber
            newDevice.selectedUserName = self.selectedUserName
            newDevice.delegate = SharingManager.sharedInstance.MapViewVC
//            self.loadingView.hide()
            self.time?.invalidate()
            self.time = nil
        }
    }
    
    //DropDown View function
    func animateWithTransition1(_ animator: AAViewAnimators) {
        self.dropDown1.aa_animate(duration: 1.5, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
                
            }
            else {
                print("Animation Done")
                if self.dropDown {
                    self.dropDown = false
                    print("dropDown Bool is \(self.dropDown)")
                }else {
                    self.dropDown = true
                    print("dropDown Bool is \(self.dropDown)")
                }
            }
        }
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    //MARK: show alert error message
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: MFMessageViewControllerDelegate method (required )
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            register = false
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            register = false
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            register = true
            self.dismiss(animated: true, completion: nil)
            
        default:
            register = false
            break;
        }
    }
    
}

extension SMSViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UITableViewDatasource method.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alluser", for: indexPath) as! AllUserCell
        
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
