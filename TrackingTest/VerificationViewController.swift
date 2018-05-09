//
//  VerificationViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/11/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import FirebaseAuth
import RSLoadingView

class VerificationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: property initialize
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet var logoImage: UIImageView!
    
    @IBOutlet weak var avoidingView: UIView!
    
    //MARK: Loading View property
    let loadingView = RSLoadingView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        // MARK: view customize (border color, shadow effect, corner radius)
        self.logoImage.layer.borderWidth = 1
        self.logoImage.layer.borderColor = UIColor.clear.cgColor
        self.logoImage.layer.shadowColor = UIColor.black.cgColor
        self.logoImage.layer.shadowOpacity = 0.16
        self.logoImage.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.logoImage.layer.cornerRadius = self.logoImage.frame.size.height/2
        self.logoImage.layer.masksToBounds = true
        
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VerificationViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    //MARK: Calls this function when the tap is recorgnized
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    // MARK: Keep inputed email
    func retrieveAccountInfo() {
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "phonenum") != nil {
            
            self.phoneNum.text = defaults.string(forKey: "phonenum")
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: SENDCODE BUTTON ACTION.
    @IBAction func SendCode(_ sender: UIButton) {
        
        let phoneNumber = self.phoneNum.text!
        
        let defaults = UserDefaults.standard
        
        defaults.set(phoneNumber, forKey: "phonenum")
        
        
        let alertController = UIAlertController(title: "Phone Number", message: "Is this your phone number? \n \(phoneNum.text!)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            
                self.loadingView.show(on: self.view)
            
            //MARK: verification phone number part.
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNum.text!) { (verificationID, error) in
                
                if error != nil {

                    print("Error \(String(describing: error?.localizedDescription))")
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                    
                        self.loadingView.hide()
                    })
                    
                    self.showAlert("Error", message: (error?.localizedDescription)!)
                }else {

                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authID")
                    
                    let login = self.storyboard?.instantiateViewController(withIdentifier: "first_login") as! LoginViewController
                    self.present(login, animated: true, completion: nil)
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                    
                        self.loadingView.hide()
                    })
                }
                
            }
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: textFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}

//MARK: extension UIColor(hexcolor)
extension UIColor {
    
    // Convert UIColor from Hex to RGB
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}
