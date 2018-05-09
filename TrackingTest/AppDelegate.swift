//
//  AppDelegate.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/09/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications
import IQKeyboardManagerSwift
import CoreData
import CoreLocation
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let requestIdentifier = "Geofencing"
    let requestIdentifierBattery = "battery"
    
    //Callkit property
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    let callManager = CallManager()
    lazy var providerDelegate: ProviderDelegate = ProviderDelegate(callManager: self.callManager)
    
    

    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    var displayCurrentLocation: Timer?
    var catchLatLngTimer: Timer?
    var currentLocationTimer: Timer?
    var deletingHistoryTimer: Timer?
    var upDateFrequencyTimer: Timer?
    var myDeviceBatteryTimer: Timer?
    var otherDeviceBatteryTimer: Timer?
    var updateFrequencyUnit = 1
    var viewDid: Bool = false
    
    var myBattery: Float = 0.0
    var batteryAlert: Bool = false
    
    var regionIdentifierArray: [String] = [String]()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    var deviceListDownloadStart: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        //MARK: current device battery level monitoring.
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        //MARK: NavigationBar backgroundColor.
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navigation")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        
        // MARK: changing status bar style and background Color.
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.black
        }
        UIApplication.shared.statusBarStyle = .lightContent
       
        // MARK: When phone number verification push notification, making badge number.
        application.applicationIconBadgeNumber = 0
        
        // MARK: Firebase configuring.
        FirebaseApp.configure()
        
        //MARK: Push Notification
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            
                if granted {
                    application.registerForRemoteNotifications()
                }
            })
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequest) in
                
                var identifiers: [String] = []
                for notification: UNNotificationRequest in notificationRequest {
                    identifiers.append(notification.identifier)
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().delegate = self
            
        }else {
            let notificationsettings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationsettings)
            UIApplication.shared.cancelAllLocalNotifications()
            UIApplication.shared.registerForRemoteNotifications()
            
            
        }
        
        // Core location delgate and permission
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // MARK: Google map API key
        GMSServices.provideAPIKey("AIzaSyChm_5FBk5vBdm3MhIdROFYxK-JXMySfso")
        GMSPlacesClient.provideAPIKey("AIzaSyChm_5FBk5vBdm3MhIdROFYxK-JXMySfso")
        
        //MARK: IQKeyboardManager enabled
        IQKeyboardManager.sharedManager().enable = true
        
        
        //checking battery level in background.
        self.myDeviceBatteryTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(AppDelegate.BatteryLevel), userInfo: nil, repeats: true)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        return true
    }
    
    //MARK: Getting my device battery level.
    func BatteryLevel() {
        
        let batteryLevel = UIDevice.current.batteryLevel
        myBattery = batteryLevel*100
        
        if myBattery < 30.0 {
            
            if !batteryAlert {
            
                //MARK: Local Notification.
                let notification = UNMutableNotificationContent()
                notification.title = "Eins Tracking!"
                notification.subtitle = "Your device's battery level is less than 30%."
                
                notification.body = "Your device's battery level is less than 30%. Please charge your battery!"
                
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
                
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: requestIdentifierBattery, content: notification, trigger: notificationTrigger)
                
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
                batteryAlert = true
            }
        }else {
            batteryAlert = false
        }
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EinsTracking")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func handleEventEnter(forRegion region: CLRegion!) {
        
        print("Geofencing entering triggered")
        
//        if UIApplication.shared.applicationState == .active {
//            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
//        }else {
//            
//            
            //MARK: Local Notification.
        let path = SharingManager.sharedInstance.phoneNumber
        var geotifications: [Geotifications] = [Geotifications]()
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
                
                geotifications.append(geotification)
                
            }
            
            if geotifications.count == 0 {
                
                print("No geotification")
            }else {
                
                //MARK: Local Notification.
                let notification = UNMutableNotificationContent()
                notification.title = "Eins Tracking!"
                notification.subtitle = "You are near any device."
                
                var index = 0
                for item in self.regionIdentifierArray {
                    if item == region.identifier {
                        notification.body = geotifications[index].note
                    }
                    index = index + 1
                }
                
                
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
                
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: self.requestIdentifier, content: notification, trigger: notificationTrigger)
                
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            }
            
            
        })
        
//        }
    }
    
    func handleEventExit(forRegion region: CLRegion!) {
        
        print("Geofence exit triggered")
//        if UIApplication.shared.applicationState == .active {
//            
//            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
//            
//        }else {
        
        let path = SharingManager.sharedInstance.phoneNumber
        var geotifications: [Geotifications] = [Geotifications]()
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
                
                geotifications.append(geotification)
                
            }
            
            if geotifications.count == 0 {
                
                print("No geotification")
            }else {
                
                //MARK: Local Notification.
                let notification = UNMutableNotificationContent()
                notification.title = "Eins Tracking!"
                notification.subtitle = "You are outside any device."
                
                var index = 0
                for item in self.regionIdentifierArray {
                    if item == region.identifier {
                        notification.body = geotifications[index].note
                    }
                    index = index + 1
                }
                
                
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
                
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: self.requestIdentifier, content: notification, trigger: notificationTrigger)
                
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            }
            
            
        })
        
        
            
//        }
    }
    
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEventEnter(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEventExit(forRegion: region)
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        
        completionHandler( [.alert,.sound,.badge])
       
    }
    
}

