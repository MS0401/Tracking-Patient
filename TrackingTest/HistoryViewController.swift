//
//  HistoryViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/09/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import RSLoadingView
import AAViewAnimator

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    //MARK: outlet initialize
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var deviceName: UILabel!
    @IBOutlet var photos: UIImageView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var photoName: UILabel!
    @IBOutlet var viaMap: UIButton!
    @IBOutlet var cellAddress: UILabel!
    @IBOutlet var cellLocation: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var dropDown: UIView!
    
    var selectDeviceName = ""
    var selectPhotoName = ""
    var selectedPhoto: UIImage!
    var drop: Bool = true
    
    var historymain: Bool = false
    var historydeviceinfo: Bool = false
    
    //MARK: RSLoadingView
    let loadingView = RSLoadingView()
    var ref: DatabaseReference!
    
    var DateHistoryArray: [History] = [History]()
    var dateArray: [DateHistory] = [DateHistory]()
    var AllHistoryArray: [[History]] = [[History]]()
    var historyPath = ""
    
    var selectedIndexPath: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Setup()
        //MARK: Firebase reference path
        self.ref = Database.database().reference()
        
        //MARK: when touch anywhere, dismissing keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HistoryViewController.DismissDropDownView))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dateArray.removeAll()
        self.DateHistoryArray.removeAll()
        self.AllHistoryArray.removeAll()
        self.DownloadingHistoryInfo()
    }
    
    func Setup() {
        
        self.dropDown.isHidden = true
        self.dropDown.layer.cornerRadius = 5
        self.dropDown.layer.masksToBounds = true
        
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.layer.masksToBounds = true
        
        self.photoView.layer.cornerRadius = 5
        
        self.photos.layer.cornerRadius = self.photos.frame.size.height/2
        self.photos.layer.masksToBounds = true
        
        self.deviceName.text = self.selectDeviceName
        self.photos.image = self.selectedPhoto
        self.photoName.text = self.selectPhotoName
        
        self.viaMap.layer.cornerRadius = self.viaMap.frame.size.height/2
        self.viaMap.layer.masksToBounds = true
    }
    
    func DownloadingHistoryInfo() {
        
        self.loadingView.show(on: view)
        
        let path = self.historyPath
        
        //MARK: Downloading history date from Firebase realtime database.
        self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/trackingDate").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            for item in snapshot.children {
                
                let child = item as! DataSnapshot
                let dateDict = child.value as! NSDictionary
                let historyDate = DateHistory(dictionary: dateDict)
                self.dateArray.append(historyDate)
            }
            
            if self.dateArray.count == 0 {
                print("No history Date")
                self.loadingView.hide()
            }else {
                
                for item in self.dateArray {
                    
                    //MARK: History downloading from Firebase
                    self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/\(item.historyYMD)").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                        for item in snapshot.children {
                            
                            let child = item as! DataSnapshot
                            let dict = child.value as! NSDictionary
                            print("NSDictionary is \(dict)")
                            let history = History(dictionary: dict)
                            self.DateHistoryArray.append(history)
                            
                        }
                        
                        // MARK: Saving into array "historyarray" of every Date.
                        self.AllHistoryArray.append(self.DateHistoryArray)
                        self.DateHistoryArray.removeAll()
                    })
                }
                
                self.tableview.reloadData()
                self.loadingView.hide()
            }
        })
        
    }
    
    func DismissDropDownView() {
        
        if self.drop == false {
            
            self.animateWithTransition(.toRight)
            
        }
    }
    
    //DropDown View function
    func animateWithTransition(_ animator: AAViewAnimators) {
        self.dropDown.aa_animate(duration: 1.5, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
                
            }
            else {
                print("Animation Done")
                if self.drop {
                    self.drop = false
                }else {
                    self.drop = true
                }
            }
        }
    }
    
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viaMap" {
            
            let viaMapController = segue.destination as! DeviceRoutViewController
            
            let selectedDateHistory: [History] = self.AllHistoryArray[self.selectedIndexPath]
            viaMapController.historyArray = selectedDateHistory
        }
    }
    
    @IBAction func DisplayingViaGoogleMap(_ sender: UIButton) {
        
        self.animateWithTransition(.toRight)
        
        self.performSegue(withIdentifier: "viaMap", sender: self)        
    }
    
    
    @IBAction func BackAction(_ sender: UIButton) {
        
        if self.historymain {
            
//            self.historymain = false
//            SharingManager.sharedInstance.backInMain = true
            let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
            self.navigationController?.popToViewController(vc!, animated: true)
            
        }else if self.historydeviceinfo {
            
            self.historydeviceinfo = false
            let  vc =  self.navigationController?.viewControllers.filter({$0 is DeviceInfoController}).first
            self.navigationController?.popToViewController(vc!, animated: true)
            
        }
    }
    
    @IBAction func GotoMapViewController(_ sender: UIButton) {
        
//        if self.historydeviceinfo {
//            SharingManager.sharedInstance.backInMain = true
//        }
        
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MapViewController}).first
        self.navigationController?.popToViewController(vc!, animated: true)
        
    }
    
    //MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryCell
        
        let tempDate = self.dateArray[indexPath.row]
        
        cell.date.text = tempDate.historyYMD
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SharingManager.sharedInstance.historyBool = true
        
        self.selectedIndexPath = indexPath.row
        let tempHistory = self.dateArray[indexPath.row]
        
        // Displaying dropDown View
        self.dropDown.isHidden = false
        
        self.cellAddress.text = tempHistory.address
        self.cellLocation.text = tempHistory.latlng
        self.cellDate.text = tempHistory.historyYMD
        
        self.animateWithTransition(.fromLeft)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.loadingView.show(on: view)
            
            //MARK: deleting selected history.
            let path = self.historyPath
            let tempHistory = self.dateArray[indexPath.row]
            let selectedHistory = tempHistory.historyYMD
            self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/\(selectedHistory)/").removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    self.showAlert("Sorry!", message: (error?.localizedDescription)!)
                    self.loadingView.hide()
                }else {
                    print("Successfully removed from Firebase database.")
                    self.loadingView.hide()
                    self.dateArray.remove(at: indexPath.row)
                    self.AllHistoryArray.remove(at: indexPath.row)
                    self.tableview.reloadData()
                }
                
            })
            
        }
        
    }
    
    //MARK: Very Important(UIGestureRecoginzerDelegate method) - UITapGestureRecognizer breaks UITableView didSelectRowAtIndexPath
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: self.tableview)
            return (tableview.indexPathForRow(at: location) == nil)
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
