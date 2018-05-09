//
//  CustomUINavigationViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/18/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
//In Side bar configuration, this viewcontroller is main.
class CustomUINavigationViewController: UINavigationController {
    
    public var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var homViewController: MapViewController!
    var othersViewController: LMOtherViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Navigation bar logo
        let logo = UIImage(named: "title_discover1")
        self.navigationBar.topItem?.titleView = UIImageView(image: logo)
        
        //self.navigationController?.toolbar.frame = CGRect(x: 0, y: 500, width: 375, height: 100)
        self.toolbar.frame = CGRect(x: 0, y: 500, width: 375, height: 100)
        
        //bar color
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        //Drop Shadow
        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationBar.layer.shadowOpacity = 0.7
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.navigationBar.layer.shadowRadius = 3
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    func homeViewController() -> MapViewController{
        
        
        if homViewController != nil{
            
            homViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MapViewController!
        }
        
        return homViewController

    }
    
    func OthersViewController() -> LMOtherViewController {
        
        if othersViewController != nil {
            
            othersViewController = self.storyboard?.instantiateViewController(withIdentifier: "othersViewController") as! LMOtherViewController!
        }
        
        return othersViewController
    }
    
    func showHomeViewController(){
        
        self.setViewControllers([self.homViewController], animated: true)
    }
    
    func showOthersViewController(){
        
        self.setViewControllers([self.othersViewController], animated: true)
    }
    
    
}
