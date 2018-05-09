//
//  ForgotPasswordViewController.swift
//  TrackingTest
//
//  Created by admin on 9/10/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RSLoadingView

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    
    var dictArray: [NSDictionary] = [NSDictionary]()
    
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    let loadingView = RSLoadingView()
    
    var userPhoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: keeping inputed user's email
        self.retrieveAccountInfo()
        
    }
    
    //Keep inputed email
    func retrieveAccountInfo() {
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "email") != nil { 
            
            self.email.text = defaults.string(forKey: "email")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangePassword(_ sender: UIButton) {
        
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter your reset password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
            
            self.loadingView.show(on: view)
            
            let user = Auth.auth().currentUser
            print("current Email: \(String(describing: user?.email))")
            
            user?.updatePassword(to: self.password.text!) { error in
                
                if error != nil {
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.loadingView.hide()
                }else {
                    
                    self.loadingView.hide()
                    
                    let alertController = UIAlertController(title: "Success!", message: "You have successfully reset password.", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                        
                        self.FirebaseLoginWithResetPassword()
                    }
                    alertController.addAction(action)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    
    func FirebaseLoginWithResetPassword() {
        
        self.loadingView.show(on: view)
        
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
    
    @IBAction func GotoLoginController(_ sender: UIButton) {
        
        let login = self.storyboard?.instantiateViewController(withIdentifier: "first_login") as! LoginViewController
        self.present(login, animated: true, completion: nil)
    }
    
    //MARK: back to verificationViewController
    @IBAction func BackVerification(_ sender: UIButton) {
        
        let verify = self.storyboard?.instantiateViewController(withIdentifier: "verification") as! VerificationViewController
        self.present(verify, animated: true, completion: nil)
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }

}
