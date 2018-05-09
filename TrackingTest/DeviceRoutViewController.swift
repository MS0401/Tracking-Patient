//
//  DeviceRoutViewController.swift
//  TrackingTest
//
//  Created by admin on 9/11/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import RSLoadingView
import Firebase
import FirebaseDatabase
import AAViewAnimator
import NVActivityIndicatorView

class DeviceRoutViewController: UIViewController, NVActivityIndicatorViewable {
    
    //MARK: outlet property initialize
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var topView: UIView!
    @IBOutlet var selectedDeviceName: UILabel!
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var dropDownView: UIView!
    
    @IBOutlet var markerAddress: UILabel!
    @IBOutlet var markerLocation: UILabel!
    @IBOutlet var markerDate: UILabel!
    
    @IBOutlet var totalDistance: UILabel!
    @IBOutlet var totalCarory: UILabel!
    
    var historyArray: [History] = [History]()
    
    //MARK: GoogleMap and Core Location initialize.
    var locationManager = CLLocationManager()
    var mapTasks = MapTasks()
    
    var tappingAddress: [String] = [String]()
    
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markerposition: CLLocationCoordinate2D!
    
    //MARK: Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var historyLocationArray: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var currentCameraCoordinate: CLLocationCoordinate2D!
    var usersMarker: [GMSMarker] = [GMSMarker]()
    var historyLocationStringArray: [String] = [String]()
    
    var totalDistanceInMeter = 0
    var index = 0
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    let loadingView = RSLoadingView()
    
    var dropDown: Bool = true
    
    var totalDistanceTimer: Timer?
    var endCalculate: Bool = false
    
    var arrPolylineAdded: [GMSPolyline] = [GMSPolyline]()
    var arrPolylinesingle: [GMSPolyline] = [GMSPolyline]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        self.Setup()
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: mapView delegate.
        mapView.delegate = self
        
        //MARK: clear mapview
        mapView.clear()
        
        locationManager.delegate = self
        
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
            self.endCalculate = true
        }
        
        for item in self.historyArray {
            let deviceLocation = item.latlng
            let coordinateString = deviceLocation.components(separatedBy: ", ")
            let coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
            
            self.historyLocationArray.append(coordinate)
            self.historyLocationStringArray.append(item.latlng)
        }
        
        let first = self.historyLocationArray[0]
        self.displayFirstLocationMarker(first)
        let camera = GMSCameraPosition.camera(withLatitude: first.latitude, longitude: first.longitude, zoom: 17)
        self.mapView.animate(to: camera)
        
        let last = self.historyLocationArray[self.historyLocationArray.count - 1]
        self.DisplayLastLocationMarker(last)
        
        
        self.NVActivityINdicator()
    }
    
    func NVActivityINdicator() {
        
        let size = CGSize(width: 50, height: 50)
        
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.lineScalePulseOut.rawValue))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.totalDistanceTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(DeviceRoutViewController.TotalDistance), userInfo: nil, repeats: false)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.historyLocationArray.removeAll()
        self.historyLocationStringArray.removeAll()
        self.totalDistanceTimer?.invalidate()
        
        for item in self.usersMarker {
            let userMarker = item
            userMarker.map = nil
        }
        
        self.usersMarker.removeAll()
        
        for item: GMSPolyline in self.arrPolylinesingle {
            item.map = nil
        }
        for item1: GMSPolyline in self.arrPolylineAdded {
            item1.map = nil
        }
        self.arrPolylinesingle.removeAll()
        self.arrPolylineAdded.removeAll()
    }
    
    func Setup() {
        
        self.arrPolylineAdded.removeAll()
        self.arrPolylinesingle.removeAll()
        self.historyLocationArray.removeAll()
        self.historyLocationStringArray.removeAll()
        self.dropDownView.isHidden = true
        
        self.dropDownView.layer.cornerRadius = 5
        self.dropDownView.layer.masksToBounds = true
        
    }
    
    func TotalDistance() {
        
            var index = 0
            for i in 0 ..< self.historyLocationStringArray.count - 1 {
                
                self.mapTasks.getDirections(self.historyLocationStringArray[i], destination: self.historyLocationStringArray[i+1], waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                    
                    if success {
                        self.drawRoute()
                        let distance = self.mapTasks.calculateTotalDistanceAndDuration()
                        self.totalDistanceInMeter = self.totalDistanceInMeter + distance
                        self.totalDistance.text = "\(self.totalDistanceInMeter) m"
                        print("Successfully calculated")
                        print("indexi is \(i)")
                        index = index + 1
                    }else {
                        
                        let path = GMSMutablePath()
                        path.addLatitude(self.historyLocationArray[i].latitude, longitude:self.historyLocationArray[i].longitude) // Sydney
                        path.addLatitude(self.historyLocationArray[i+1].latitude, longitude:self.historyLocationArray[i+1].longitude)
                        
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = .red
                        polyline.strokeWidth = 5.0
                        polyline.title = "single"
                        polyline.map = self.mapView
                        
                        self.arrPolylinesingle.append(polyline)
                        index = index + 1
                    }
                    
                    print("TotalIndex is \(index)")
                    if index == self.historyLocationStringArray.count - 1 {
                        
                        self.stopAnimating()
                        
                    }
                })
            }
    }
    
    // Display route between addresses
    func drawRoute() {
        var routePolyline: GMSPolyline!
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
    
    @IBAction func BackAction(_ sender: UIButton) {
        
        let  vc =  self.navigationController?.viewControllers.filter({$0 is HistoryViewController}).first
        self.navigationController?.popToViewController(vc!, animated: true)
        
    }
    
    // Set Current Location Marker
    func displayFirstLocationMarker(_ coordinate: CLLocationCoordinate2D) {
        let firstLocationMarker: GMSMarker!
        
        firstLocationMarker = GMSMarker(position: coordinate)
        firstLocationMarker.map = mapView
        firstLocationMarker.appearAnimation = .pop
        firstLocationMarker.iconView = self.FirstLocationMarkerView()
        self.usersMarker.append(firstLocationMarker)
    }
    
    // Custom Current markerInfoWindow (custom marker and Main Marker name)
    func FirstLocationMarkerView() -> UIView {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0 , width: 80, height: 100))
        wrapperView.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: 15.0, y: 35.0, width: 50.0, height: 55.0))
        
        imageView.image = UIImage(named: "red_pin.png")
        wrapperView.addSubview(imageView)
        
        let strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        strLabel.backgroundColor = UIColor.clear
        strLabel.text = "First"
        strLabel.font = UIFont(name: "Bold", size: 17.0)
        strLabel.textAlignment = .center
        strLabel.textColor = .black
        wrapperView.addSubview(strLabel)
        
        return wrapperView
    }
    
    // Custom Current markerInfoWindow (custom marker and Main Marker name)
    func LastLocationMarkerView() -> UIView {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0 , width: 80, height: 100))
        wrapperView.backgroundColor = .clear
        
        let imageView = UIImageView(frame: CGRect(x: 15.0, y: 35.0, width: 50.0, height: 55.0))
        
        imageView.image = UIImage(named: "red_pin.png")
        wrapperView.addSubview(imageView)
        
        let strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        strLabel.backgroundColor = UIColor.clear
        strLabel.text = "Last"
        strLabel.font = UIFont(name: "Bold", size: 17.0)
        strLabel.textAlignment = .center
        strLabel.textColor = .black
        wrapperView.addSubview(strLabel)
        
        return wrapperView
    }
    
    // Set Device Location Marker
    func DisplayLastLocationMarker(_ coordinate: CLLocationCoordinate2D) {
        
        let locationDeviceMarker: GMSMarker!
        
        locationDeviceMarker = GMSMarker(position: coordinate)
        locationDeviceMarker.map = mapView
        locationDeviceMarker.appearAnimation = GMSMarkerAnimation.pop
        locationDeviceMarker.iconView = self.LastLocationMarkerView()
        
        self.usersMarker.append(locationDeviceMarker)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}

//GMSMapViewDelegate method
extension DeviceRoutViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.markerposition = marker.position
        
        var index = 0
        
        for item in self.historyLocationArray {
            if item.latitude == marker.position.latitude && item.longitude == marker.position.longitude {
                
                let selectHistory = self.historyArray[index]
                
                self.markerAddress.text = selectHistory.address
                self.markerLocation.text = selectHistory.latlng
                self.markerDate.text = selectHistory.time
                
                self.dropDownView.isHidden = false
                animateWithTransition(.fromLeft)
                
            }
            index = index + 1
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        if self.dropDown == false {
            animateWithTransition(.toRight)
        }
    }
    
    // MARK: customize info window.
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let customInfoWindow = Bundle.main.loadNibNamed("View", owner: self, options: nil)?.first! as! CustomInfoWindow
        
        if SharingManager.sharedInstance.currentLoc.latitude == marker.position.latitude && SharingManager.sharedInstance.currentLoc.longitude == marker.position.longitude {
            
            customInfoWindow.infoName.text = "Main"
            customInfoWindow.backgroundColor = UIColor.clear
        }
        
        return customInfoWindow
    }
}


// MARK: - CLLocationManagerDelegate
extension DeviceRoutViewController:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        
//        if self.endCalculate {
//            self.displayCurrentLocationMarker()
//        }
        
    }
}
