//
//  SignUpViewController.swift
//  TrackingTest
//
//  Created by admin on 9/6/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RSLoadingView
import AAViewAnimator
import CoreLocation
import Photos

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var dropDownView: UIView!
    @IBOutlet var dropDownImage: UIImageView!
    @IBOutlet var verifyCode: UITextField!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var verifyBtn: UIButton!
    
    
    //MARK: Location Manager - CoreLocation Framework.
    var locationManager = CLLocationManager()
    
    //MARK: Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var appDelegate: AppDelegate!
    
    var userPhoneNumber = ""
    
    //MARK: BackgroundTaskIdentifier for backgrond update location
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    var backgroundTaskIdentifier2: UIBackgroundTaskIdentifier!
    
    //MARK: first sharing current location
    var firstShared: Bool = true
    
    var downloadingBool: Bool = false
    
    var dictArray: [NSDictionary] = [NSDictionary]()
    
    // Loading View property
    let loadingView = RSLoadingView()
    
    // ImagePickerController property
    let imagePicker = UIImagePickerController()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ImagePickerController delegate confirm.
        self.imagePicker.delegate = self
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        self.Setup()
        
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
        
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func Setup() {
        
        self.CircleImage(profileImage: self.profileImage)
        self.CircleImage(profileImage: self.dropDownImage)
        self.cancelBtn.layer.cornerRadius = self.cancelBtn.frame.size.height/2
        self.cancelBtn.layer.masksToBounds = true
        self.verifyBtn.layer.cornerRadius = self.verifyBtn.frame.size.height/2
        self.verifyBtn.layer.masksToBounds = true
        self.dropDownView.isHidden = true
        self.dropDownView.layer.cornerRadius = 10
        self.dictArray.removeAll()
    }
    
    //MARK: Calls this function when the tap is recorgnized
    func dismissKeyboard() {
        
        view.endEditing(true)
    }

    @IBAction func SignUpAction(_ sender: UIButton) {
        
        let save_email = self.email.text!
        let defaults = UserDefaults.standard
        defaults.set(save_email, forKey: "save_email")
        
        
        if self.email.text == "" {
            self.showAlert("Warning!", message: "You didn't input your email. Please input your email.")
        }else if self.password.text == "" {
            self.showAlert("Warning!", message: "You didn't input your password. Please input your password.")
        }else if self.userName.text == "" {
            self.showAlert("Warning!", message: "You didn't input your name. Please input your name.")
        }else if self.profileImage.image == UIImage(named: "profile.png") {
            self.showAlert("Warning!", message: "You didn't select your profile image. Please select your profile image.")
        }else if self.phoneNumber.text == "" {
            self.showAlert("Warning!", message: "You didn't input phone number. Please input phone number.")
        }else {
            
            self.loadingView.show(on: view)
            
            
            //MARK: verification phone number part.
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber.text!) { (verificationID, error) in
                
                if error != nil {
                    
                    print("Error \(String(describing: error?.localizedDescription))")
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.loadingView.hide()
                    })
                    
                    self.showAlert("Error", message: (error?.localizedDescription)!)
                }else {
                    
                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authID")
                    self.dropDownView.isHidden = false
                    self.dropDownImage.image = self.profileImage.image
                    self.verifyCode.text = ""
                    self.animateWithTransition(.fromTop)
                    self.loadingView.hide()
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func CancelDropDown(_ sender: UIButton) {
        
        animateWithTransition(.toBottom)
        
    }
    
    @IBAction func PhoneNumberVerify(_ sender: UIButton) {
        
        animateWithTransition(.toBottom)
        
        //MARK: obtaining phone AuthCredential
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authID")!, verificationCode: self.verifyCode.text!)
        
        self.loadingView.show(on: view)
        
        
        
        //phone auth function part
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if error != nil {
                
                print("Error \(String(describing: error?.localizedDescription))")
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.loadingView.hide()
                })
                
                self.showAlert("Error", message: (error?.localizedDescription)!)
                
            }else {
                
                let userInfo = user?.providerData[0]
                print("Provider id \(String(describing: userInfo?.providerID))")
                
                print("Phone number is \(String(describing: (user?.phoneNumber)!))")
                
                // Making Firebase path node
                self.userPhoneNumber = (user?.phoneNumber)!
                SharingManager.sharedInstance.phoneNumber = self.userPhoneNumber
                
                self.FirebaseEmailSignUp()
            }
            
        }
        
        
    }
    
    func FirebaseEmailSignUp() {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            if error == nil {
                print("You have successfully signed up")
                
                //MARK: Uploading user information for chatting.
                user?.sendEmailVerification(completion: nil)
                                
                let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
                let imageData = UIImageJPEGRepresentation(self.profileImage.image!, 0.1)
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        
                        
                        let values = ["name": self.userName.text!, "email": self.email.text!, "profilePicLink": path!]
                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                let userInfo = ["email" : self.email.text!, "password" : self.password.text!]
                                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                
                                self.Uploading()
                            }
                        })
                    }
                })
                
                
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                self.loadingView.hide()
            }
        }
    }
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //MARK: Firebase uploading function/// ******** important ********
        
        //getting image URL from library or photoAlbum.
        var data: NSData = NSData()
        if let image = self.profileImage.image {
            
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        }
        
        let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        let userName = self.userName.text!
        let userEmail = self.email.text!
        let userPassword = self.password.text!
        
        
        let dataInformation: NSDictionary = ["imageURL": imageURL, "userName": userName, "userEmail": userEmail, "userPassword": userPassword, "phoneNumber": self.userPhoneNumber]
        
        print("my phone number is \(self.userPhoneNumber)")
        
        //MARK: add firebase child node
        let child1 = ["/TrackingTest/\(self.userPhoneNumber)/Profile/profile/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                
                self.UploadingUsersPhoneNumber()
            }else {
                self.loadingView.hide()
                self.showAlert("Error!", message: (error?.localizedDescription)!)
            }
        })
    }
    
    func UploadingUsersPhoneNumber() {
        
        //MARK: History downloading from Firebase
        self.ref.child("TrackingTest/Users").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                print(dict)
                self.dictArray.append(dict)
                
            }
            self.downloadingBool = true
            
            if self.dictArray.count == 0 { // MARK: Phone number uploading to Firebase.
                
                let usersPhoneNumber: NSDictionary = ["phoneNumber": self.userPhoneNumber, "email": self.email.text!]
                
                // MARK: add firebase child node
                let child = ["/TrackingTest/Users/\(self.GetCurrentTime())": usersPhoneNumber]
                
                //MARK: Write data to Firebase
                self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        
                        let Root = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! NVController
                        self.present(Root, animated: true, completion: nil)
                        self.loadingView.hide()
                    }else {
                        self.loadingView.hide()
                        self.showAlert("Error!", message: (error?.localizedDescription)!)
                    }
                })
                
            }else { // MARK: Case registered users count is not 0, Phone number uploading to Firebase.
                
                var duplicate: Bool = false
                
                for item in self.dictArray {
                    
                    let itemNumber = item["phoneNumber"] as! String
                    
                    if self.userPhoneNumber == itemNumber {
                        print("Duplicated signed up.")
                        duplicate = true
                        break
                    }
                }
                
                if duplicate {
                    print("Duplicated signed up.")
                    let Root = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! NVController
                    self.present(Root, animated: true, completion: nil)
                    self.loadingView.hide()
                }else {
                    
                    let usersPhoneNumber: NSDictionary = ["phoneNumber": self.userPhoneNumber, "email": self.email.text!]
                    
                    // MARK: add firebase child node
                    let child = ["/TrackingTest/Users/\(self.GetCurrentTime())": usersPhoneNumber]
                    
                    //MARK: Write data to Firebase
                    self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
                        
                        if error == nil {
                            
                            let Root = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! NVController
                            self.present(Root, animated: true, completion: nil)
                            self.loadingView.hide()
                        }else {
                            self.loadingView.hide()
                            self.showAlert("Error!", message: (error?.localizedDescription)!)
                        }
                    })
                    
                }
            }
        })
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    @IBAction func SelectImage(_ sender: UIButton) {
        
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.imagePicker.modalPresentationStyle = .popover
                self.imagePicker.sourceType = .photoLibrary// or savedPhotoAlbume
                self.imagePicker.allowsEditing = true
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: UIImagePickerContollerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.backgroundColor = UIColor.clear
            self.profileImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //DropDown View function
    func animateWithTransition(_ animator: AAViewAnimators) {
        self.dropDownView.aa_animate(duration: 1.0, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
            }
            else {
                print("Animation Done")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: Getting current Time
    func GetCurrentTime() -> String {
        
        //MARK: Making project name - year.
        let format_year = DateFormatter()
        format_year.dateFormat = "yyyy"
        let year = format_year.string(from: Date())
        
        //MARK: Making project name - month.
        let format_month = DateFormatter()
        format_month.dateFormat = "MM"
        let month = format_month.string(from: Date())
        
        //MARK: Making project name - day.
        let format_day = DateFormatter()
        format_day.dateFormat = "dd"
        let day = format_day.string(from: Date())
        
        //MARK: Making project name - hour.
        let format_hour = DateFormatter()
        format_hour.dateFormat = "HH"
        let hour = format_hour.string(from: Date())
        
        //MARK: Making project name - minutes.
        let format_minute = DateFormatter()
        format_minute.dateFormat = "mm"
        let minute = format_minute.string(from: Date())
        
        //MARK: Making project name - second.
        let format_second = DateFormatter()
        format_second.dateFormat = "ss"
        let second = format_second.string(from: Date())
        
        let date = "\(year)Y\(month)Mth\(day)D\(hour)H\(minute)Mi\(second)S"
        
        return date
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - CLLocationManagerDelegate
extension SignUpViewController:  CLLocationManagerDelegate {
    
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


