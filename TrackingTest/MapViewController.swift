//
//  MapViewController.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/09/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase
import FirebaseDatabase
import RSLoadingView
import AAViewAnimator
import CoreData
import UserNotifications

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
    case transit
}

class MapViewController: UIViewController {
   
    
    //MARK: outlet property initialize
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var selectedDeviceName: UILabel!
    @IBOutlet var arraw_downup: UIImageView!
    
    @IBOutlet var deviceNumberView: UIView!
    @IBOutlet var deviceNumber: UILabel!
    @IBOutlet var search: UIButton!
    @IBOutlet var devices: UIButton!
    @IBOutlet var refresh: UIButton!
    @IBOutlet var devicelistTable: UITableView!
    
    @IBOutlet var dropDownView: UIView!
    
    @IBOutlet var deviceNameofMarker: UILabel!
    @IBOutlet var markerAddress: UILabel!
    @IBOutlet var markerLat: UILabel!
    @IBOutlet var markerLng: UILabel!
    @IBOutlet var markerDistance: UILabel!
    @IBOutlet var markerTotalTime: UILabel!
    @IBOutlet var currentAddress: UILabel!
    @IBOutlet var detailInfoBtn: UIButton!
    @IBOutlet var deviceHistoryBtn: UIButton!
    
    var DeviceInfos: [DeviceInfo] = [DeviceInfo]()
    var refreshStart: Bool = false
    var selectedDeviceNumber: Int!
        
    var flag: Bool = true
    var dropDown: Bool = true
    
    var travelMode = TravelModes.transit
    
    //MARK: GoogleMap and Core Location initialize.
    var locationManager = CLLocationManager()
    var mapTasks = MapTasks()
    
    var tappingAddress: [String] = [String]()
    
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var usersMarker = [GMSMarker]()
    var markerposition: CLLocationCoordinate2D!
    
    //MARK: Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var deviceLocationArray: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var currentCameraCoordinate: CLLocationCoordinate2D!
    
    var routePolyline: GMSPolyline!
    var arrPolylineAdded: [GMSPolyline] = [GMSPolyline]()
    var arrPolylinesingle: [GMSPolyline] = [GMSPolyline]()
    var circleRouteArray: [GMSCircle] = [GMSCircle]()
    
    var appDelegate: AppDelegate!
    
    var firstBool = true
    var templocation: String!
    var templatlang: String!
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    
    let loadingView = RSLoadingView()
    
    var backFromHistory: Bool = false
    
    var viewDismiss: Bool = false
    
    // MARK: Geofencing property
    var geotifications: [Geotifications] = [Geotifications]()
    
    //MARK: Battery Level property
    var myBattery: Float = 0.0
    var batteryNotify: [Bool] = [Bool]()
    var zoomArray: [Float] = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 15.0, 17.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: View initialize.
        self.Setup()
        
        //MARK: Device List Table hidden
        self.devicelistTable.isHidden = true
        self.devicelistTable.layer.cornerRadius = 5
        
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: mapView delegate.
        mapView.delegate = self
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        
        //MARK: clear mapview
        mapView.clear()
        
        locationManager.delegate = self
        
        //MARK: Gets the exact location of the user.(for region monitoring)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //MARK: Request permission to use Location service
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        //MARK: Start the update of user's Location
        locationManager.startUpdatingLocation()
        
        //MARK: Set compass of map view
        mapView.settings.compassButton = true
        
        //MARK: Start the update of user's Location
        if CLLocationManager.locationServicesEnabled() {
            
            //MARK: Location Accuracy, properties
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
            
            self.currentCameraCoordinate = SharingManager.sharedInstance.currentLoc
            self.setuplocationMarker(self.currentCameraCoordinate!)
        }
        

    }
    
    func ZoomInAnimation() {
        
//        self.delay(seconds: 0.2, withCompletionHandler: {
        
            let zoomOut = GMSCameraUpdate.zoom(to: kGMSMinZoomLevel)
            self.mapView.animate(with: zoomOut)
            
//            self.delay(seconds: 0.15, withCompletionHandler: {
//                
//                let vancouver = CLLocationCoordinate2DMake(self.currentCameraCoordinate.latitude, self.currentCameraCoordinate.longitude)
//                let vancouverCam = GMSCameraUpdate.setTarget(vancouver)
//                self.mapView.animate(with: vancouverCam)
        
                self.delay(seconds: 0.3, withCompletionHandler: {
                    
//                    let zoomIn = GMSCameraUpdate.zoom(to: 17.0)
//                    self.mapView.animate(with: zoomIn)
                    
                    let camera = GMSCameraPosition.camera(withLatitude: (self.currentCameraCoordinate.latitude), longitude: (self.currentCameraCoordinate.longitude), zoom: 17)
                    self.mapView.animate(to: camera)
                })
//            })
//        })
        
    }
    
    func ZoomInAnimationCoordinate(latitude: CLLocationDegrees, logitude: CLLocationDegrees) {
        
//        self.delay(seconds: 0.2, withCompletionHandler: {
        
            let zoomOut = GMSCameraUpdate.zoom(to: kGMSMinZoomLevel)
            self.mapView.animate(with: zoomOut)
            
//            self.delay(seconds: 0.15, withCompletionHandler: {
//                
//                let vancouver = CLLocationCoordinate2DMake(latitude, logitude)
//                let vancouverCam = GMSCameraUpdate.setTarget(vancouver)
//                self.mapView.animate(with: vancouverCam)
        
                self.delay(seconds: 0.3, withCompletionHandler: {
                    
                    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: logitude, zoom: 17)
                    self.mapView.animate(to: camera)
                })
//            })
//        })
        
    }
    
   
    func delay(seconds: Double, withCompletionHandler completionHandler: @escaping (() -> Void)) {
        
        let when = DispatchTime.now() + seconds // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            completionHandler()
        }
    }
    
    
    func Setup() {
        
        self.dropDownView.isHidden = true
        
        //MARK: Top and Bottom view Shadow
        //MARK: Drop Shadow
        self.topView.layer.shadowColor = UIColor.black.cgColor
        self.topView.layer.shadowOpacity = 0.7
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.topView.layer.shadowRadius = 3
             
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOpacity = 0.7
        self.bottomView.layer.shadowOffset = CGSize(width: 3.0, height: 0)
        self.bottomView.layer.shadowRadius = 3
        
        self.detailInfoBtn.layer.cornerRadius = self.detailInfoBtn.frame.size.height/2
        self.detailInfoBtn.layer.shadowColor = UIColor.black.cgColor
        self.detailInfoBtn.layer.shadowOpacity = 0.7
        self.detailInfoBtn.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.detailInfoBtn.layer.shadowRadius = 3
        self.detailInfoBtn.layer.masksToBounds = true
        
        
        self.deviceHistoryBtn.layer.cornerRadius = self.deviceHistoryBtn.frame.size.height/2
        self.deviceHistoryBtn.layer.shadowColor = UIColor.black.cgColor
        self.deviceHistoryBtn.layer.shadowOpacity = 0.7
        self.deviceHistoryBtn.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.deviceHistoryBtn.layer.shadowRadius = 3
        self.deviceHistoryBtn.layer.masksToBounds = true
        
        self.dropDownView.layer.cornerRadius = 5
        self.dropDownView.layer.masksToBounds = true
        
        //MARK: SelectedDeviceNumber View radius.
        self.deviceNumberView.layer.cornerRadius = self.deviceNumberView.frame.height/2
        
        self.selectedDeviceName.text = "select"
        self.deviceNumber.text = "0"
        
        
        
    }
    
    //MARK: gettting other device battery level and sending local notification.
    func BatteryLevelOtherDevice() {
        
        if self.appDelegate.deviceListDownloadStart == false {
            
            for item in 0 ..< self.DeviceInfos.count - 1 {
                
                self.ref.child("TrackingTest/\(self.DeviceInfos[item].phoneNumber)/CurrentLocation").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                    
                    for item1 in snapshot.children {
                        let child = item1 as! DataSnapshot
                        let dict = child.value as! NSDictionary
                        
                        let battery = dict["batteryLevel"] as! Float
                        let templevel = Float(self.DeviceInfos[item].batteryLevel)!
                        if battery < templevel {
                            
                            if self.batteryNotify[item] == false {
                                
                                //MARK: Local Notification.
                                let notification = UNMutableNotificationContent()
                                notification.title = "Eins Tracking!"
                                notification.subtitle = "\(self.DeviceInfos[item].name) device's battery level is less than \(self.DeviceInfos[item].batteryLevel)%."
                                
                                notification.body = "\(self.DeviceInfos[item].name) device's battery level is less than \(self.DeviceInfos[item].batteryLevel)%. Would you please notify to charge battery?"
                                
                                notification.sound = UNNotificationSound.default()
                                
                                //To Present image in notification
                                if let path = Bundle.main.path(forResource: "local_notification", ofType: "png") {
                                    let url = URL(fileURLWithPath: path)
                                    
                                    do {
                                        let attachment = try UNNotificationAttachment(identifier: "localNotification", url: url, options: nil)
                                        notification.attachments = [attachment]
                                    } catch {
                                        print("attachment not found.")
                                    }
                                }
                                
                                let identity = "batteryotherDevice"
                                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                let request = UNNotificationRequest(identifier: identity, content: notification, trigger: notificationTrigger)
                                
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                self.batteryNotify[item] = true
                            }
                        }else {
                            self.batteryNotify[item] = false
                        }
                        
                    }
                })
            }
        }
    }
    
    //MARK: Uploading current location method
    func CurrentLocationUploading() {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            //MARK: checking network connection is true or false.
            if Reachability.isConnectedToNetwork() == true {
                
                let currentLocation = SharingManager.sharedInstance.currentLocation
                let path = SharingManager.sharedInstance.phoneNumber
                
                let batterylevel = UIDevice.current.batteryLevel
                self.myBattery = batterylevel*100
                //MARK: Uploading current location to Firebase database.
                let dataInformation: NSDictionary = ["currentLocation": currentLocation, "batteryLevel": self.myBattery]
                
                //MARK: add firebase child node
                let child1 = ["/TrackingTest/\(path)/CurrentLocation/currentLocation": dataInformation] // profile Image uploading
                
                //MARK: Write data to Firebase
                self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        print("Successfully uploaded current location")
                        
                        
                    }else {
                        self.showAlert("Error!", message: (error?.localizedDescription)!)
                    }
                })
                
            }else {
                self.showAlert("No Internet Connection", message: "Make sure your device is connected to the internet.")
            }
        })
    }
    
    //MARK: Uploading Tracking History
    func UploadingTrackingHistory() {
        
        let coordinate = SharingManager.sharedInstance.currentLoc
        self.GetAddressFromlntandlngUploading(lantitude: (coordinate?.latitude)!, longigude: (coordinate?.longitude)!)
        
    }
    
    //MARK: Get address string from latitude and longitude and uploading to Firebase database.
    func GetAddressFromlntandlngUploading(lantitude: Double, longigude: Double) {
        
        let reverseGeoCoder = GMSGeocoder()
        let coordinate = CLLocationCoordinate2DMake(lantitude, longigude)
        reverseGeoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: {(placeMark, error) -> Void in
            if error == nil {
                if let placeMarkObject = placeMark {
                    if (placeMarkObject.results()?.count)! > 0 {
                        self.tappingAddress = (placeMarkObject.firstResult()?.lines)! // You can get address here
                        
                        var Addressxx: String = ""
                        for i in self.tappingAddress {
                            Addressxx = Addressxx + i + " "
                        }
                        
                        //MARK: Firebase history uploading function/// ******** important ********
                        
                        let dataInformation: NSDictionary = ["address": Addressxx, "latlng": SharingManager.sharedInstance.currentLocation, "time": self.GetCurrentTime(), "date": self.GetCurrentDate()]
                        let path = SharingManager.sharedInstance.phoneNumber
                        //MARK: add firebase child node
                        let child1 = ["/TrackingTest/\(path)/TrackingHistory/trackingHistory/\(self.GetCurrentYMD())/\(self.GetCurrentHMS())/": dataInformation] // profile Image uploading
                        
                        //MARK: Write data to Firebase
                        
                        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
                            
                            if error == nil {
                                print("Successfully uploaded history.")
                                
                                // MARK: Firebase Uploading history date.
                                let uploadingDate: NSDictionary = ["address": Addressxx, "latlng": SharingManager.sharedInstance.currentLocation, "uploadYMD": self.GetCurrentYMD(), "date": self.GetCurrentDate()]
                                let child = ["/TrackingTest/\(path)/TrackingHistory/trackingHistory/trackingDate/\(self.GetCurrentYMD())/": uploadingDate]
                                self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
                                    
                                    if error == nil {
                                        print("Successfully uploading history date")
                                    }else {
                                        print((error?.localizedDescription)!)
                                    }
                                    
                                })
                            }else {
                                print((error?.localizedDescription)!)
                            }
                        })
                        
                    } else {
                        //Do Nothing
                    }
                } else {
                    //Do Nothing
                }
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    //MARK: Get address string from latitude and longitude and displaying device location info.
    func GetAddressFromlntandlngDisplaying(lantitude: Double, longigude: Double) {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            let reverseGeoCoder = GMSGeocoder()
            
            let coordinate = CLLocationCoordinate2DMake(lantitude, longigude)
            reverseGeoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: {(placeMark, error) -> Void in
                if error == nil {
                    if let placeMarkObject = placeMark {
                        if (placeMarkObject.results()?.count)! > 0 {
                            self.tappingAddress = (placeMarkObject.firstResult()?.lines)! // You can get address here
                            
                            var Addressxx: String = ""
                            for i in self.tappingAddress {
                                Addressxx = Addressxx + i + " "
                            }
                            
                            //MARK: Displaying Device info on Dropdown view.
                            // Getting device Name of marker
                            for item in 0 ..< self.deviceLocationArray.count {
                                if self.deviceLocationArray[item].latitude == coordinate.latitude && self.deviceLocationArray[item].longitude == coordinate.longitude {
                                    
                                    self.deviceNameofMarker.text = self.DeviceInfos[item].name
                                }
                            }
                            
                            
                            // showing getting marker location address
                            self.markerAddress.text = Addressxx
                            
                            // getting marker latitude and logitude
                            self.markerLat.text = String(describing: coordinate.latitude)
                            self.markerLng.text = String(describing: coordinate.longitude)
                            
                            // getting distance between marker location and current location.
                            let markerlocation = "\(coordinate.latitude), \(coordinate.longitude)"
                            let currentlocation = SharingManager.sharedInstance.currentLocation
                            
                            self.mapTasks.getDirections(markerlocation, destination: currentlocation, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                                if success {
                                    let distance = self.mapTasks.calculateTotalDistanceAndDuration()
                                    if distance == 0 {
                                        self.markerDistance.text = "0"
                                        self.markerTotalTime.text = "0 min"
                                    }else {
                                        self.markerDistance.text = String(describing: distance)
                                        self.markerTotalTime.text = String(describing: distance/300) + " min"
                                    }                                    
                                    
                                    // getting current locatoin address
                                    self.GetCurrentAddressFromlntandlng(lantitude: SharingManager.sharedInstance.currentLoc.latitude, longigude: SharingManager.sharedInstance.currentLoc.longitude)
                                    
                                }else {
                                    
                                    let coordinate0 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                    let coordinate1 = CLLocation(latitude: SharingManager.sharedInstance.currentLoc.latitude, longitude: SharingManager.sharedInstance.currentLoc.longitude)
                                    let distanceInmeter = coordinate0.distance(from: coordinate1)
                                    
                                    self.markerDistance.text = String(describing: distanceInmeter)
                                    self.markerTotalTime.text = String(describing: distanceInmeter/300) + " min"
                                    
                                    // getting current locatoin address
                                    self.GetCurrentAddressFromlntandlng(lantitude: SharingManager.sharedInstance.currentLoc.latitude, longigude: SharingManager.sharedInstance.currentLoc.longitude)
                                    
                                    print("Distance is \(distanceInmeter)")
                                    
                                }

                            })
                            
                        } else {
                            //Do Nothing
                        }
                    } else {
                        //Do Nothing
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        })
    }
    
    //MARK: get current address
    //MARK: Get address string from latitude and longitude.
    func GetCurrentAddressFromlntandlng(lantitude: Double, longigude: Double) {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            let reverseGeoCoder = GMSGeocoder()
            let coordinate = CLLocationCoordinate2DMake(lantitude, longigude)
            reverseGeoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: {(placeMark, error) -> Void in
                if error == nil {
                    if let placeMarkObject = placeMark {
                        if (placeMarkObject.results()?.count)! > 0 {
                            self.tappingAddress = (placeMarkObject.firstResult()?.lines)! // You can get address here
                            
                            var Addressxx: String = ""
                            for i in self.tappingAddress {
                                Addressxx = Addressxx + i + " "
                            }
                            
                            self.currentAddress.text = Addressxx
                            
                            self.dropDownView.isHidden = false
                            self.animateWithTransition(.fromBottom)
                            self.loadingView.hide()
                            
                        } else {
                            //Do Nothing
                        }
                    } else {
                        //Do Nothing
                    }
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        })
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            //MARK: Firebase uploading background
            // Current location Uploading background.
            if SharingManager.sharedInstance.firstStart == true {
                
                self.CurrentLocationUploading()
                self.appDelegate.currentLocationTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(MapViewController.CurrentLocationUploading), userInfo: nil, repeats: true)
                
                // Own uploading location info background.
                self.UploadingTrackingHistory()
                self.appDelegate.catchLatLngTimer = Timer.scheduledTimer(timeInterval: 1800.0, target: self, selector: #selector(MapViewController.UploadingTrackingHistory), userInfo: nil, repeats: true)
                
                // Deleting location history a week ago background.
                self.appDelegate.deletingHistoryTimer = Timer.scheduledTimer(timeInterval: 3600.0, target: self, selector: #selector(MapViewController.DownloadingDate), userInfo: nil, repeats: true)
                
                // Notification User's device battery level.
                self.appDelegate.otherDeviceBatteryTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(MapViewController.BatteryLevelOtherDevice), userInfo: nil, repeats: true)
    
                self.appDelegate.upDateFrequencyTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(MapViewController.UpdateFrequency), userInfo: nil, repeats: true)
            }
        })
        
        if SharingManager.sharedInstance.firstStart == true {
            
            self.loadAllGeotifications()
            
        }
        
        if SharingManager.sharedInstance.firstStart == true || SharingManager.sharedInstance.changeList == true {
            
            DispatchQueue.main.async(execute: { () -> Void in
            
                self.deviceLocationArray.removeAll()
                self.DeviceInfos.removeAll()
                self.batteryNotify.removeAll()
                self.DownloadingDeviceList()
                
                
            })
            
            DispatchQueue.main.async(execute: { () -> Void in
            
                SharingManager.sharedInstance.firstStart = false
                SharingManager.sharedInstance.changeList = false
            })
            
            // MARK: Important
            self.appDelegate.viewDid = true
            
        }
        
    }
    
    // MARK: downloading every device's location by updateFrequency and updating device's location.
    func UpdateFrequency() {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            print("before updating")
            
            
            
            for i in 0 ..< self.DeviceInfos.count {
                
                let frequency = Int(self.DeviceInfos[i].locationUpdateFrequency)!
                if self.appDelegate.updateFrequencyUnit % frequency != 0 {
                    self.appDelegate.updateFrequencyUnit = self.appDelegate.updateFrequencyUnit + 1
                    continue
                    
                }
                print("item1 is \(self.DeviceInfos[i].phoneNumber)")
                print("after updating")
                self.ref.child("TrackingTest/\(self.DeviceInfos[i].phoneNumber)/CurrentLocation").observeSingleEvent(of: DataEventType.value, with: { snapshots in
                    
                    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
                    var coordinateArray: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                    for item2 in snapshots.children {
                        let child1 = item2 as! DataSnapshot
                        let dict1 = child1.value as! NSDictionary
                        print("dict is \(dict1)")
                        let updatedLocationString = dict1["currentLocation"] as! String
                        
                        let coordinateString = updatedLocationString.components(separatedBy: ", ")
                        coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
                        print("deviceLocationArray count is \(self.deviceLocationArray.count)")
                        print("Coordinate is \(coordinateString)")
                        coordinateArray.append(coordinate)
                    }
                    
                    if coordinateArray.count != 0 {
                        
                        if self.usersMarker.count > 0 {
                            for item in self.usersMarker {
                                if item.title == self.DeviceInfos[i].name {
                                    
                                    print("self.usersMarker.count is \(self.usersMarker.count)")
                                    print("index is \(i)")
                                    //MARK: deleting selected marker.
                                    let userMarker = item
                                    userMarker.map = nil
                                    self.usersMarker.remove(at: i)
                                    //MARK: getting updated marker and inserting "usersMarker" array.
                                    self.setupDeviceUpdatedLocationMarker(coordinate, index: i)
                                    
                                    if self.circleRouteArray.count > 0 && self.geotifications.count > 0 {
                                        
                                        let circle: GMSCircle = self.circleRouteArray[i]
                                        circle.map = nil
                                        self.circleRouteArray.remove(at: i)
                                        self.CircleRouteUpdate(coordinate: coordinate, index: i)
                                    }
                                    
                                    print("UpdateFrequency usersMarker")
                                    
                                }
                            }
                        }
                        
                        if self.deviceLocationArray.count > 0 {
                            
                            self.deviceLocationArray.remove(at: i)
                            self.deviceLocationArray.insert(coordinate, at: i)
                            print("UpdateFrequency deviceLocationArray")
                        }
                        
                        self.appDelegate.updateFrequencyUnit = self.appDelegate.updateFrequencyUnit + 1
                    }
                })
            }
        })
    }

    // MARK: downloading "uploading Date" froom Firebase database and Deleting location History.
    func DownloadingDate() {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            let path = SharingManager.sharedInstance.phoneNumber
            
            var dateHistoryArray: [DateHistory] = [DateHistory]()
            
            // MARK: Downloading uploadingDate from Firebase.
            self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/trackingDate").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                
                for item in snapshot.children {
                    
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let dateHistory = DateHistory(dictionary: dict)
                    dateHistoryArray.append(dateHistory)
                }
                
                for item in dateHistoryArray {
                    if item.historyDate < self.GetCurrentDate() {
                        
                        let limitedDate = self.GetCurrentDate() - 6
                        if limitedDate > item.historyDate {
                            self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/trackingDate/\(item.historyYMD)/").removeValue(completionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/\(item.historyYMD)/").removeValue(completionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            print("Successfully deleted device location history a week ago.")
                                        }
                                    })
                                }
                                
                            })
                        }
                        
                    }else {
                        
                        let limitedDate = self.GetCurrentDate() + item.historyDate - 6
                        if limitedDate > item.historyDate {
                            
                            self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/trackingDate/\(item.historyYMD)/").removeValue(completionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    self.ref.child("TrackingTest/\(path)/TrackingHistory/trackingHistory/\(item.historyYMD)/").removeValue(completionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            print("Successfully deleted device location history a week ago.")
                                        }
                                    })
                                }
                                
                            })
                        }
                    }
                }
                
            })
        })
    }
    
    // MARK: downloading devicelist array
    func DownloadingDeviceList() {
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.loadingView.show(on: self.view)
        })
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            let path = SharingManager.sharedInstance.phoneNumber
            
            // MARK: deleting Route from Google Map View.
            for root: GMSPolyline in self.arrPolylineAdded {
                if root.title! == "route" {
                    root.map = nil
                }
            }
            self.arrPolylineAdded.removeAll()
            
            for item: GMSPolyline in self.arrPolylinesingle {
                if item.title! == "single" {
                    item.map = nil
                }
            }
            self.arrPolylinesingle.removeAll()
            
            for circle: GMSCircle in self.circleRouteArray {
                
                circle.map = nil
            }
            self.circleRouteArray.removeAll()
            
            //MARK: deleting all marker exception current locatoin marker.
            for item in self.usersMarker {
                let userMarker = item
                userMarker.map = nil
            }
            self.usersMarker.removeAll()
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.ZoomInAnimation()
            })
            
            
//            self.currentCameraCoordinate = SharingManager.sharedInstance.currentLoc
//            //            self.mapView.camera = GMSCameraPosition(target: cameraCoordinate!, zoom: 10.7, bearing: 0, viewingAngle: 0)
//            let camera = GMSCameraPosition.camera(withLatitude: (self.currentCameraCoordinate.latitude), longitude: (self.currentCameraCoordinate.longitude), zoom: 17)
//            self.mapView.animate(to: camera)
            
            //MARK: History downloading from Firebase
            self.ref.child("TrackingTest/\(path)/DeviceList").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                
                for item in snapshot.children {
                    
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    
                    let deviceInfo = DeviceInfo(dictionary: dict)
                    self.DeviceInfos.append(deviceInfo)
                    
                    self.batteryNotify.append(false)
                    
                }
                
                if self.DeviceInfos.count == 0 {
                    print("No Device")
                    
                    self.devicelistTable.reloadData()
                    self.deviceNumber.text = String(describing: self.DeviceInfos.count)
                    
                    
                    self.loadingView.hide()
                }else {
                    self.devicelistTable.reloadData()
                    self.deviceNumber.text = String(describing: self.DeviceInfos.count)
                    self.DownloadingDeviceLocation()
                    
                }
                
            })
        })
        
    }
    
    //MARK: downloading device location.
    func DownloadingDeviceLocation() {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            var devicePhoneNumberArray: [String] = [String]()
            
            for item in self.DeviceInfos {
                
                let devicePhoneNumber = item.phoneNumber
                devicePhoneNumberArray.append(devicePhoneNumber)
                
            }
            
            
            
            for item in self.usersMarker {
                let userMarker = item
                userMarker.map = nil
            }
            self.usersMarker.removeAll()
            
            var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
            
            //MARK: downloading device location of device list.
            for i in 0 ..< devicePhoneNumberArray.count {
                
                self.ref.child("TrackingTest/\(devicePhoneNumberArray[i])/CurrentLocation").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                    
                    for item1 in snapshot.children {
                        
                        let child = item1 as! DataSnapshot
                        let dict = child.value as! NSDictionary
                        let deviceLocation = dict["currentLocation"] as! String
                        
                        let coordinateString = deviceLocation.components(separatedBy: ", ")
                        
                        coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
                        
                        self.deviceLocationArray.append(coordinate)
                    }
                    
                    print("DeviceLocationArray count is \(self.deviceLocationArray.count)")
                    
                    self.setupDeviceLocationMarker(coordinate, index: i)
                    
                    self.CircleRoute(coordinate: coordinate, index: i)
                    
                    let tempIndex = i + 1
                    if  tempIndex == devicePhoneNumberArray.count {
                        
                        self.appDelegate.deviceListDownloadStart = false
                        self.loadingView.hide()
                        
                        
                    }
                })
                
            }
        })
    }
    
    func CircleRoute(coordinate: CLLocationCoordinate2D, index: Int) {
        
        let circle: GMSCircle = GMSCircle(position: coordinate, radius: self.geotifications[index].radius)
        circle.fillColor = UIColor(red: 110/255, green: 96/255, blue: 254/255, alpha: 0.5)
        circle.strokeColor = UIColor.blue
        circle.strokeWidth = 0.5
        circle.map = self.mapView
        self.circleRouteArray.append(circle)
    }
    
    func CircleRouteUpdate(coordinate: CLLocationCoordinate2D, index: Int) {
        
        if self.geotifications.count > 0 {
            
            let circle: GMSCircle = GMSCircle(position: coordinate, radius: self.geotifications[index].radius)
            circle.fillColor = UIColor(red: 110/255, green: 96/255, blue: 254/255, alpha: 0.5)
            circle.strokeColor = UIColor.blue
            circle.strokeWidth = 0.5
            circle.map = self.mapView
            self.circleRouteArray.insert(circle, at: index)
            
        }
        
        
    }
    
    //MARK: Geofencing part.*********** important ********************************************
    func startMonitoring(geotification: Geotifications) {
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert("Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert("Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        
        let region = self.region(withGeotification: geotification)
        
        locationManager.startMonitoring(for: region)

    }
    
    func stopMonitoring(geotification: Geotifications) {
        
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else {
                continue}
            var index = 0
            for item in self.appDelegate.regionIdentifierArray {
                if item == region.identifier {
                    self.appDelegate.regionIdentifierArray.remove(at: index)
                }
                index = index + 1
            }
            locationManager.stopMonitoring(for: circularRegion)
            
        }
    }
    
    func region(withGeotification geotification: Geotifications) -> CLCircularRegion {
        
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        self.appDelegate.regionIdentifierArray.append(region.identifier)
        //ON ENTER PUSH NOTIFICATION
        return region
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        
        self.geotifications.removeAll()
        
        let path = SharingManager.sharedInstance.phoneNumber
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        self.ref.child("TrackingTest/\(path)/Geotifications").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            for item1 in snapshot.children {
                
                let child = item1 as! DataSnapshot
                let dict = child.value as! NSDictionary
                let tempString = dict["coordinate"] as! String
                let coordinateString = tempString.components(separatedBy: ", ")
                coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
                
                let note = dict["note"] as! String
                let identifier = dict["identifier"] as! String
                let radiusString = dict["radius"] as! String
                let radius = Double(radiusString)!
                
                let geotification = Geotifications.init(coordinate: coordinate, radius: radius, identifier: identifier, note: note)
                
                self.geotifications.append(geotification)
                
            }
            
            if self.geotifications.count == 0 {
                
                self.devicelistTable.reloadData()
                self.deviceNumber.text = String(describing: self.DeviceInfos.count)
                
                for item in self.usersMarker {
                    let userMarker = item
                    userMarker.map = nil
                }
                self.usersMarker.removeAll()
                
            }else {
                print("Load Geotification is \(self.geotifications.count)")
            }
        })
    }

    func InsertGeotificationsToCoreData(geotification: Geotifications) {
        
        let path = SharingManager.sharedInstance.phoneNumber
        
        let coordinateString = "\(geotification.coordinate.latitude), \(geotification.coordinate.longitude)"
        let identifier = geotification.identifier
        let note = geotification.note
        let radiusString = "\(geotification.radius)"
        
        let geotificate: NSDictionary = ["coordinate": coordinateString, "radius": radiusString, "identifier": identifier, "note": note]
        
        
        //MARK: Write data to Firebase
        self.ref.child("/TrackingTest/\(path)/Geotifications/\(note)") .setValue(geotificate, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                
                print("Successfully inserted geotification")
            }else {
                print("error uploading geotification.")
            }
        })
        
    }
    
    func UpdateGeotificationFromCoreData(geotification: Geotifications, index: Int) {
        
        let path = SharingManager.sharedInstance.phoneNumber
        
        let coordinateString = "\(geotification.coordinate.latitude), \(geotification.coordinate.longitude)"
        let identifier = geotification.identifier
        let note = geotification.note
        let radiusString = "\(geotification.radius)"
        
        let geotificate: NSDictionary = ["coordinate": coordinateString, "radius": radiusString, "identifier": identifier, "note": note]
        
        let child = ["/TrackingTest/\(path)/Geotifications/\(note)/": geotificate]
        
        
        self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                
               print("Successfully Geotification Updated")
                
            }else {
                print("Geotification updating failed")
            }
            
        })
    }
    
    
    func DeleteGeotificationsFromCoreData(geotification: Geotifications, index: Int) {
        
        let path = SharingManager.sharedInstance.phoneNumber
        print(geotification.note)
        self.ref.child("/TrackingTest/\(path)/Geotifications/\(geotification.note)").removeValue(completionBlock: { (error, ref) in
            
            if error == nil {
                print("Successfully geotification deleted")
            }else {
                print("Failed geotification deleted")
            }
        })
        
    }
    
    //***************************************************************************************
    
    //MARK: uploading user's location history into Firebase.
    func UploadingLocationInformation() {
        
        DispatchQueue.main.async(execute: { () -> Void in
        
            //MARK: checking network connection is true or false.
            if Reachability.isConnectedToNetwork() == true {
                
                self.templocation = SharingManager.sharedInstance.uploadingLocation
                let currentlocation = SharingManager.sharedInstance.currentLocation
                
                self.mapTasks.getDirections(self.templocation, destination: currentlocation, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                    if success {
                        
                        let distance = self.mapTasks.calculateTotalDistanceAndDuration()
                        if self.firstBool {
                            self.templatlang = SharingManager.sharedInstance.uploadingLocation
                            self.mapTasks.getDirections(self.templatlang, destination: currentlocation, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                                if success {
                                    let perMinuteDistance = self.mapTasks.calculateTotalDuration()
                                    print("Distance: \(distance)")
                                    print("PerminuteDistance: \(perMinuteDistance)")
                                    if distance != 0 && perMinuteDistance != 0 {
                                        
                                        if distance > 4000 && distance / perMinuteDistance < 10 {
                                            
                                            //MARK: uploading function
                                            self.GetAddressFromlntandlngUploading(lantitude: SharingManager.sharedInstance.uploadingLoc.latitude, longigude: SharingManager.sharedInstance.uploadingLoc.longitude)
                                            
                                            //MARK: initialize property
                                            self.firstBool = true
                                            SharingManager.sharedInstance.uploadingLocation = currentlocation
                                            SharingManager.sharedInstance.uploadingLoc = SharingManager.sharedInstance.currentLoc
                                            
                                        }else {
                                            self.firstBool = false
                                            
                                        }
                                    }
                                }else {
                                    print("First status is \(status)")
                                    
                                }
                            })
                        }else {
                            self.mapTasks.getDirections(self.templatlang, destination: currentlocation, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                                if success {
                                    
                                    let perMinuteDistance = self.mapTasks.calculateTotalDuration()
                                    print("Distance1: \(distance)")
                                    print("PerminuteDistance1: \(perMinuteDistance)")
                                    if distance != 0 && perMinuteDistance != 0 {
                                        
                                        if distance > 4000 && distance / perMinuteDistance < 10 {
                                            
                                            //uploading function
                                            self.GetAddressFromlntandlngUploading(lantitude: SharingManager.sharedInstance.uploadingLoc.latitude, longigude: SharingManager.sharedInstance.uploadingLoc.longitude)
                                            
                                            self.firstBool = true
                                            SharingManager.sharedInstance.uploadingLocation = currentlocation
                                            
                                            SharingManager.sharedInstance.uploadingLoc = SharingManager.sharedInstance.currentLoc
                                            
                                        }else {
                                            self.firstBool = false
                                            
                                        }
                                    }
                                }else {
                                    print("Second status is \(status)")
                                }
                            })
                        }
                        
                    } else {
                        print(status)
                        print("Uploading location is same current location.")
                        
                    }
                })
                
            }else {
                self.showAlert("No Internet Connection", message: "Make sure your device is connected to the internet.")
            }
        })
    }
    
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
        
        let currentTime = "\(year)-\(month)-\(day) \(hour):\(minute):\(second)"
        
        return currentTime
        
    }
    
    //MARK: Getting current YMD(year, month, day)
    func GetCurrentYMD() -> String {
        
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
        
        let date = "\(year)-\(month)-\(day)"
        
        return date
        
    }
    
    func GetCurrentDate() -> Int {
        
        //MARK: Getting Current date.
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let Intday = components.day!
        
        print("Current Date is \(Intday)")
        
        return Intday
    }
    
    func GetCurrentHMS() -> String {
        
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
        
        let HMS = "\(hour):\(minute):\(second)"
        
        return HMS
    }
    
    //MARK: Action for side bar
    @IBAction func LeftMenuAction(_ sender: UIBarButtonItem) {
        
        self.sideBarController.showMenuViewController(in: LMSideBarControllerDirection.left)
    }
    
    //MARK: hidden or show device lsit table.
    @IBAction func DeviceTableArraw(_ sender: UIButton) {
        
        if flag {
            self.flag = false
            UIView.transition(with: self.devicelistTable, duration: 0.3, options: .transitionCurlDown, animations: { self.devicelistTable.isHidden = false }, completion: nil)
            
            self.arraw_downup.image = UIImage(named: "arraw_up.png")
            
        } else {
            self.flag = true
            UIView.transition(with: self.devicelistTable, duration: 0.3, options: .transitionCurlUp, animations: { self.devicelistTable.isHidden = true }, completion: nil)
            
            self.arraw_downup.image = UIImage(named: "arraw_down.png")
        }
        
    }
    
    @IBAction func RefreshAction(_ sender: UIButton) {
        
        
        // MARK: deleting Route from Google Map View.
        for root: GMSPolyline in self.arrPolylineAdded {
            if root.title! == "route" {
                root.map = nil
            }
        }
        
        for item: GMSPolyline in self.arrPolylinesingle {
            if item.title! == "single" {
                item.map = nil
            }
        }
        
        //MARK: deleting all marker exception current locatoin marker.
        for item in usersMarker {
            let userMarker = item
            userMarker.map = nil
        }
        
        self.deviceLocationArray.removeAll()
        self.DeviceInfos.removeAll()
        self.DownloadingDeviceList()
        
    }
    
    @IBAction func DisplayingDrawRoute(_ sender: UIButton) {
        self.loadingView.show(on: view)
        
        if self.selectedDeviceNumber != nil {
            
            DispatchQueue.main.async(execute: { () -> Void in
            
                self.ShowDirection(index: self.selectedDeviceNumber)
            })
            
        }else {
            self.showAlert("Warning!", message: "You didn't select device. Please select device for drawing route.")
            self.loadingView.hide()
        }
        
    }
    
    @IBAction func GotoDeviceInfoController(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "mainEdit", sender: self)
        
    }
    
    @IBAction func GotoHisoryController(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "historymain", sender: self)
        
    }
    
    @IBAction func GotoDeviceListController(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "deviceList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.loadingView.show(on: view)
        
        if segue.identifier == "mainEdit" {
            
            print("Prepare \(self.geotifications.count)")
            self.animateWithTransition(.toRight)
            
            let coordinateString = self.markerLat.text! + ", " + self.markerLng.text!
            var index = 0
            for item in self.deviceLocationArray {
                
                let itemString = "\(item.latitude), \(item.longitude)"
                if itemString == coordinateString {
                    
                    let deviceInfo = segue.destination as! DeviceInfoController
                    deviceInfo.editDeviceInfo = self.DeviceInfos[index]
                    if self.geotifications.count != 0 {
                        for geotify in self.geotifications {
                            if "You are near \(deviceInfo.editDeviceInfo.name)" == geotify.note {
                                deviceInfo.selectedGeotification = geotify
                            }
                        }
                    }
                    
                    deviceInfo.delegate = self
                    
                    self.loadingView.hide()
                    break
                }
                index = index + 1
            }
            
        }else if segue.identifier == "historymain" {
            
            self.animateWithTransition(.toRight)
            print("SharingManager is : \(SharingManager.sharedInstance.currentLocation)")
            print("markerPosition is : \(self.markerposition)")
            if SharingManager.sharedInstance.currentLoc.latitude == self.markerposition.latitude && SharingManager.sharedInstance.currentLoc.longitude == self.markerposition.longitude { // Case tap current location marker (main marker).
                
                print("current selected marker is main marker. You can show history about current locatoin.!")
                
            }else { // Case if not.
                
                let coordinateString = self.markerLat.text! + ", " + self.markerLng.text!
                print("markerLat: \(self.markerLat.text!), markerLng: \(self.markerLng.text!)")
                
                if self.markerLat.text! == "lat" || self.markerLng.text! == "lng" {
                    self.loadingView.hide()
                    self.showAlert("Warning!", message: "You didn't select device's marker. Please tap marker you want show.")
                    
                }else {
                    var index = 0
                    for item in self.deviceLocationArray {
                        
                        let itemString = "\(item.latitude), \(item.longitude)"
                        if itemString == coordinateString {
                            
                            let deviceInfo = segue.destination as! HistoryViewController
                            deviceInfo.historyPath = self.DeviceInfos[index].phoneNumber
                            print("path: \(deviceInfo.historyPath)")
                            deviceInfo.selectedPhoto = self.DeviceInfos[index].image
                            deviceInfo.selectDeviceName = self.DeviceInfos[index].name
                            deviceInfo.selectPhotoName = self.DeviceInfos[index].name
                            deviceInfo.historymain = true
                            print("historyBool : \(deviceInfo.historymain)")
                            
                            self.loadingView.hide()
                            break
                        }
                        index = index + 1
                    }
                    
                    
                }
                
            }
        }else if segue.identifier == "deviceList" {
            let deviceList = segue.destination as! DeviceListController
            
            deviceList.delegate = self
            print("Self.geotifications of count is \(self.geotifications.count)")
            SharingManager.sharedInstance.MapViewVC = self
            self.loadingView.hide()
        }
    }
      
    
    //Show Direction.
    func ShowDirection(index: Int) {
        
        // Get route information between two addresses
        let current = SharingManager.sharedInstance.currentLocation
        
        // GETTTING DIRECTION.
        let coordinate = self.deviceLocationArray[index]
        let destinationLat = coordinate.latitude
        let destinationLng = coordinate.longitude
        let cameraCoordinate = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLng)
        self.mapView.camera = GMSCameraPosition(target: cameraCoordinate, zoom: 17, bearing: 0, viewingAngle: 0)
        let destinationAddress = "\(destinationLat), \(destinationLng)"
        self.travelMode = .transit
        self.mapTasks.getDirections(current, destination: destinationAddress, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
            
            if success {
                self.loadingView.hide()
                self.drawRoute(index: index)
                
            } else {
                
                let alertController = UIAlertController(title: "Warning!", message: "You can't route because request travel mode are not available, If you want to show route by airplane, please click OK button", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    
                    let path = GMSMutablePath()
                    path.addLatitude(SharingManager.sharedInstance.currentLoc.latitude, longitude:SharingManager.sharedInstance.currentLoc.longitude) // Sydney
                    path.addLatitude(destinationLat, longitude:destinationLng)
                    
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = .blue
                    polyline.strokeWidth = 5.0
                    polyline.title = "single"
                    polyline.map = self.mapView
                    
                    self.arrPolylinesingle.append(polyline)
                    self.loadingView.hide()
                    
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                    
                    self.loadingView.hide()
                }
                
                alertController.addAction(action)
                alertController.addAction(cancel)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
        })

        
    }
    
    // Set Current Location Marker
    func setuplocationMarker(_ coordinate: CLLocationCoordinate2D) {
        
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = mapView
        locationMarker.opacity = 0.85
        locationMarker.title = "main"
        locationMarker.iconView = self.customCurrentMarkerView()
    }
    
    // Set Device Location Marker
    func setupDeviceLocationMarker(_ coordinate: CLLocationCoordinate2D, index: Int) {
        
        let locationDeviceMarker: GMSMarker!
        
        locationDeviceMarker = GMSMarker(position: coordinate)
        locationDeviceMarker.map = mapView
        locationDeviceMarker.opacity = 0.85
        locationDeviceMarker.title = self.DeviceInfos[index].name
        locationDeviceMarker.iconView = self.customDeviceView(coordinate: coordinate, count: index)
        
        self.usersMarker.append(locationDeviceMarker)
    }
    
    // Set Device updated Location Marker
    func setupDeviceUpdatedLocationMarker(_ coordinate: CLLocationCoordinate2D, index: Int) {
        
        let locationDeviceMarker: GMSMarker!
        
        locationDeviceMarker = GMSMarker(position: coordinate)
        locationDeviceMarker.map = mapView
        locationDeviceMarker.opacity = 0.85
        locationDeviceMarker.title = self.DeviceInfos[index].name
        locationDeviceMarker.iconView = self.customDeviceView(coordinate: coordinate, count: index)
        
        self.usersMarker.insert(locationDeviceMarker, at: index)
    }
    
    // Custom markerInfoWindow (custom marker and device name)
    func customDeviceView(coordinate: CLLocationCoordinate2D, count: Int) -> UIView {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0 , width: 120, height: 90))
        wrapperView.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: 35.0, y: 35.0, width: 50.0, height: 55.0))
        
        imageView.image = UIImage(named: "red_pin.png")
        wrapperView.addSubview(imageView)
        
        let strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        strLabel.backgroundColor = UIColor.clear
        strLabel.text = self.DeviceInfos[count].name
        strLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        strLabel.textAlignment = .center
        strLabel.textColor = .black
        wrapperView.addSubview(strLabel)
        
        //blinkingView
        let blinkingView = UIView(frame: CGRect(x: 57, y: 25, width: 6, height: 6))
        blinkingView.backgroundColor = UIColor.red
        blinkingView.layer.cornerRadius = blinkingView.frame.size.height/2
        blinkingView.layer.masksToBounds = true
        blinkingView.isHidden = true
        
        blinkingView.startBlinking(duration: 0.25)
        wrapperView.addSubview(blinkingView)
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            blinkingView.isHidden = false
            blinkingView.startBlinking(duration: 0.25)
        }else {
            
            blinkingView.isHidden = true
            blinkingView.stopBlinking()
        }
        
        return wrapperView
    }
    
    // Custom Current markerInfoWindow (custom marker and Main Marker name)
    func customCurrentMarkerView() -> UIView {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0 , width: 80, height: 90))
        wrapperView.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: 15.0, y: 35.0, width: 50.0, height: 55.0))
        
        imageView.image = UIImage(named: "blue_pin.png")
        wrapperView.addSubview(imageView)
        
        let strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        strLabel.backgroundColor = UIColor.clear
        strLabel.text = "Main"
        strLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        strLabel.textAlignment = .center
        strLabel.textColor = .black
        wrapperView.addSubview(strLabel)
        
        return wrapperView
    }
    
    // Display route between addresses
    func drawRoute(index: Int) {
        
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 4.0
        routePolyline.strokeColor = UIColor.red
        routePolyline.isTappable = true
        routePolyline.map = mapView
        routePolyline.title = "route"
        
        self.arrPolylineAdded.append(routePolyline)
    }
    
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    //DropDown View function
    func animateWithTransition(_ animator: AAViewAnimators) {
        self.dropDownView.aa_animate(duration: 1.5, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
            }
            else {
                print("Animation Done")
                if self.dropDown {
                    self.dropDown = false
                }else {
                    self.dropDown = true
                }
            }
        }
    }

    // Set Current Location Marker
    func displayCurrentLocationMarker() {
        
        let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        locationMarker.map = nil
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = mapView
        locationMarker.title = "main"
        locationMarker.opacity = 0.85
        locationMarker.iconView = self.customCurrentMarkerView()
        
    }
    
}

//MARK: UITableviewDelegate and UITableViewDatasource methods
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.DeviceInfos.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: DeviceList Talbe configure.
        let cell = tableView.dequeueReusableCell(withIdentifier: "maindevicelist", for: indexPath) as! MainDeviceListCell
        
        var deviceList: DeviceInfo = DeviceInfo()
        deviceList = self.DeviceInfos[indexPath.row]
        
        cell.deviceName.text = deviceList.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedDeviceNumber = indexPath.row
        
        //MARK: Display selected device's current location.
        let coordinate = self.deviceLocationArray[indexPath.row]
        let destinationLat = coordinate.latitude
        let destinationLng = coordinate.longitude
        
        self.ZoomInAnimationCoordinate(latitude: destinationLat, logitude: destinationLng)
        
        // MARK: display selected device's nickName.
        self.selectedDeviceName.text = self.DeviceInfos[indexPath.row].name
        
        self.flag = true
        UIView.transition(with: self.devicelistTable, duration: 0.3, options: .transitionCurlUp, animations: { self.devicelistTable.isHidden = true }, completion: nil)
        
        self.arraw_downup.image = UIImage(named: "arraw_down.png")
        
        // MARK: deleting Route from Google Map View.
        for root: GMSPolyline in self.arrPolylineAdded {
            if root.title! == "route" {
                root.map = nil
            }
        }
        
        for item: GMSPolyline in self.arrPolylinesingle {
            if item.title! == "single" {
                item.map = nil
            }
        }
        
    }
    
}


//GMSMapViewDelegate method
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.markerposition = marker.position
        
        if marker.title != "main" {
            
            self.loadingView.show(on: view)
            
            // MARK: Displaying Dropdown View
            self.GetAddressFromlntandlngDisplaying(lantitude: marker.position.latitude, longigude: marker.position.longitude)
            
        }
        

        
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if self.dropDown == false {
            animateWithTransition(.toRight)
        }
    }
    
}


// MARK: - CLLocationManagerDelegate
extension MapViewController:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        
     
        if self.appDelegate.viewDid {
            
            self.locationMarker.map = nil
            self.displayCurrentLocationMarker()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Monitoring is started for region with identifier: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error.localizedDescription)")
    }
}

// MARK: AddGeotificationViewControllerDelegate
extension MapViewController: AddGeotificationsViewControllerDelegate {
    
    func addGeotificationViewController(controller: RegisterDeviceController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String) {
        
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotifications(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
        // 2
        startMonitoring(geotification: geotification)
        self.geotifications.append(geotification)
        print("Geotification Insert count is \(self.geotifications.count)")
        InsertGeotificationsToCoreData(geotification: geotification)
        
    }
    
}

extension MapViewController: UpdateGeotificationsViewControllerDelegate {
    func updateGeotificationViewController(controller: DeviceInfoController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String) {
        
//        let deleteGeotification = Geotifications(coordinate: removeCoordinate, radius: removeRadius, identifier: removeIdentifer, note: removeNote)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotifications(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
        
        
        
        for i in 0 ..< geotifications.count {
            
            if geotification.note == geotifications[i].note {
                stopMonitoring(geotification: geotifications[i])
                self.geotifications.remove(at: i)
                print("Geotification before update Count is \(self.geotifications.count)")
                startMonitoring(geotification: geotification)
                self.geotifications.insert(geotification, at: i)
                print("Geotification after update Count is \(self.geotifications.count)")
                UpdateGeotificationFromCoreData(geotification: geotification, index: i)
                break
            }
        }
        
    }
    
    func removeGeotificationViewController(controller: DeviceInfoController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String) {
        
        let geotification = Geotifications(coordinate: coordinate, radius: radius, identifier: identifier, note: note)
        
        for index in 0 ..< self.geotifications.count {
            
            if self.geotifications[index].note == geotification.note {
                
                DeleteGeotificationsFromCoreData(geotification: geotification, index: index)
            }
        }
        
    }
    
}

extension MapViewController: DeviceListGeotificationsViewControllerDelegate {
    
    func removeFromDeviceListGeotificationViewController(controller: DeviceListController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String) {
        
        let geotification = Geotifications(coordinate: coordinate, radius: radius, identifier: identifier, note: note)
        print("Count is \(self.geotifications.count)")
        for index in 0 ..< self.geotifications.count {
            
            if self.geotifications[index].note == geotification.note {
                stopMonitoring(geotification: geotification)
                self.geotifications.remove(at: index)
                print("Geotification Remove count is \(self.geotifications.count)")
                DeleteGeotificationsFromCoreData(geotification: geotification, index: index)
                break
            }
        }
    }
}




