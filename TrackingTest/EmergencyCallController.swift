//
//  EmergencyCallController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 09/01/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import SystemConfiguration
import MobileCoreServices

class EmergencyCallController: UIViewController, UITextFieldDelegate {
    
    //MARK: outlet property
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var CallBtn: UIButton!
    @IBOutlet var emergencyNumber: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Setup()
        
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EmergencyCallController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
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
        
        self.CallBtn.layer.borderWidth = 1
        self.CallBtn.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    @IBAction func EmergencyCall(_ sender: UIButton) {
        
        let url: NSURL = URL(string: "TEL://1235678797")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Calls this function when the tap is recorgnized
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    //MARK: UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    
   
    
    
    
}
