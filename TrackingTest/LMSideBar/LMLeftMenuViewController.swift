//
//  LMLeftMenuViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/19/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import RSLoadingView

class LMLeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //The Titles of Side bar.
    var menuTitles = [0: "Home", 1: "History"]
    //The images of Side bar.
    var cellimage = [0: "home.png", 1: "history2.png"]
    
    //initialize.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var toolBar_left: UIToolbar!
    
    var historyController : UIViewController!
    
    let loadingView = RSLoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Circle images
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.layer.borderWidth = 0.5
        self.avatarImageView.layer.borderColor = UIColor.clear.cgColor
        self.avatarImageView.clipsToBounds = true
        self.tableView.register(UINib(nibName: "LelfMenuViewCell", bundle: nil), forCellReuseIdentifier: "LM")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let historyViewController = storyboard.instantiateViewController(withIdentifier: "history") as! HistoryViewController
        self.historyController = UINavigationController(rootViewController: historyViewController)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RemoveMenu(_ sender: Any) {
        self.sideBarController.hideMenuViewController(true)
    }
    // Table View DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LM", for: indexPath) as! LelfMenuViewCell
        cell.titleLabel.text = self.menuTitles[indexPath.row]
        cell.titleLabel.textColor = UIColor(white: 1, alpha: 1)
        cell.backgroundColor = UIColor.clear
        cell.cellImage.image = UIImage(named: cellimage[indexPath.row]!)
        return cell
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        
        
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect( x:0, y:0, width:width, height:height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    // TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0 {
            
            self.sideBarController.hideMenuViewController(true)
            
        }else if indexPath.row == 1 {
            
//            returnToFavourites()
//            self.sideBarController.hideMenuViewController(true)
            let hisoty = self.storyboard?.instantiateViewController(withIdentifier: "history") as! HistoryViewController
            self.present(hisoty, animated: true, completion: nil)
            
        }
    }
    
}

extension UIViewController {
    func returnToFavourites()
    {
        // you return to the storyboard wanted by changing the name
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let mainNavigationController = storyBoard.instantiateViewController(withIdentifier: "mainNavigationController") as! UINavigationController
        // Set animated to false
        let favViewController = storyBoard.instantiateViewController(withIdentifier: "history")
        self.present(mainNavigationController, animated: false, completion: {
            mainNavigationController.pushViewController(favViewController, animated: false)
            
//            leftmenuController.loadingView.hide()
//            leftmenuController.sideBarController.hideMenuViewController(true)
        })
    }
    
}
