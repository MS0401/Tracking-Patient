//
//  LMOtherViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/19/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit

class LMOtherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func leftMenuButtonTapped(_ sender: Any){
        
        self.sideBarController.showMenuViewController(in: LMSideBarControllerDirection.left)
    }
}
