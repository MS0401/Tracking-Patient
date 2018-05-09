//
//  MapTasks.swift
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/10/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapTasks: NSObject {

    // Request base URL for the geocoding
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    //APIkey
    let apikey = "AIzaSyChm_5FBk5vBdm3MhIdROFYxK-JXMySfso"
    
    // Address information dictionary
    var lookupAddressResults: Dictionary<String, Any>!
    var fetchedFormattedAddress:  String!            /* address */
    var fetchedAddressLatitude: Double!              /* latitude of coordinate */
    var fetchedAddressLongitude: Double!             /* longitude of coordinate */
    
    // Request base URL for the direction
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    // Route information dictionary
    var selectedRoute: Dictionary<String, Any>!
    
    // Overview polyline dictionary
    var overviewPolyline: Dictionary<String, Any>!
    
    // Coordinate information
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    
    
    // Address information
    var originAddress: String!
    var destinationAddress: String!
    
    // Distance information
    var totalDistanceInMeters: UInt = 0
    var totalDistance: String!
    var distanceForExpense: String!
    
    // Duration information
    var totalDurationInSeconds: UInt = 0
    var totalDuration: String!
    var durationForExpense: String!
    var calculatedDuration: Int!
    
    
    override init() {
        super.init()
    }
    
    // Get address information with address string
    func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        if let lookupAddres = address {
            
            // Set the request URL
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddres
            geocodeURLString = geocodeURLString.addingPercentEscapes(using: String.Encoding.utf8)!
            let geocodeURL = URL(string: geocodeURLString)
            
            // Get address from Google map API
            DispatchQueue.main.async(execute: { () -> Void in
                
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                
                do {
                    let dictionary: Dictionary<String, Any> =  try JSONSerialization.jsonObject(with: geocodingResultsData!, options: .mutableContainers) as! Dictionary<String, Any>
                    //                    print("JSON => \(dictionary)")
                    
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        
                        let allResults = dictionary["results"] as! Array<Dictionary<String, Any>>
                        self.lookupAddressResults = allResults[0]
                        
                        // Keep the most important values
                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<String, Any>
                        self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<String, Any>)["lat"] as! NSNumber).doubleValue
                        self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<String, Any>)["lng"] as! NSNumber).doubleValue
                        print("Address => \(self.fetchedFormattedAddress!)")
                        print("\(self.fetchedAddressLatitude!), \(self.fetchedAddressLongitude!)")
                        
                        completionHandler(status, true)
                        
                    } else {
                        
                        completionHandler(status, false)
                    }
                } catch {
                    
                    print("error => \(error)")
                }
            })
        }
    }
    
    // Get route information between addresses with addresses string
    func getDirections(_ origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        if let originLocation = origin {
            
            if let destinationLocation = destination {
                
                // Set the request URL
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                let directionsURL = URL(string: directionsURLString)
                
                // Get the route information from Google map API
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let directionsData = try? Data(contentsOf: directionsURL!)
                    
                    do {
                        let dictionary: Dictionary<String, Any> =  try JSONSerialization.jsonObject(with: directionsData!, options: .mutableContainers) as! Dictionary<String, Any>
                        //                        print("JSON => \(dictionary)")
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, Any>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, Any>
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, Any>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, Any>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, Any>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            self.originAddress = legs[0]["start_address"] as! String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                            
//                            self.calculateTotalDistanceAndDuration()
                            //                            self.parser()
                            
                            completionHandler(status, true)
                            
                        } else {
                            completionHandler(status, false)
                        }
                    } catch {
                        
                        print("error => \(error)")
                    }
                    
                    
                })
                
            } else {
                completionHandler("Destination is nill", false)
            }
        } else {
            completionHandler("Origin is nill", false)
        }
        
    }
    
    func calculateTotalDistanceAndDuration() -> Int {
        
        print("CalculateTotalDistanceAndDuration started")
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, Any>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            
            // Get total distance for meters
            totalDistanceInMeters += (leg["distance"] as! Dictionary<String, Any>)["value"] as! UInt
            
            // Get total duration for seconds
            totalDurationInSeconds += (leg["duration"] as! Dictionary<String, Any>)["value"] as! UInt
        }
        
        // Convert meters to mileage
        let distanceInMileage: Double = Double(totalDistanceInMeters) / 1609.34             /* 1mi = 1609.34m */
        
        totalDistance = "\(Int(round(distanceInMileage))) mi"
        distanceForExpense = "\(Int(round(distanceInMileage)))"

        
        // Convert seconds to minutes
        let durationInMins: UInt = totalDurationInSeconds / 60
        
        let durationInHours: UInt = durationInMins / 60
        let durationInMinutes: UInt = durationInMins % 60
        let formatter = NumberFormatter()
        
        formatter.minimumIntegerDigits = 2
        
        let hourString = formatter.string(from: NSNumber(value: durationInHours))
        let minuteString = formatter.string(from: NSNumber(value: durationInMinutes))
        
        durationForExpense = hourString! + ":" + minuteString!
        calculatedDuration = Int(durationInMins)
        
        if durationInMins < 2 {
            
            totalDuration = "\(durationInMins) min"
            
        } else {
            
            totalDuration = "\(durationInMins) mins"
        }

        let totalDistnaceInMeters_Int = Int(totalDistanceInMeters)
        print("TotalDistanceInMeter")
        
        return totalDistnaceInMeters_Int
        
    }
    
    // calculating duration
    func calculateTotalDuration() -> Int {
        
        print("CalculateTotalDuration started")
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, Any>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            
            // Get total distance for meters
            totalDistanceInMeters += (leg["distance"] as! Dictionary<String, Any>)["value"] as! UInt
            
            // Get total duration for seconds
            totalDurationInSeconds += (leg["duration"] as! Dictionary<String, Any>)["value"] as! UInt
        }
        
        // Convert meters to mileage
        let distanceInMileage: Double = Double(totalDistanceInMeters) / 1609.34             /* 1mi = 1609.34m */
        
        totalDistance = "\(Int(round(distanceInMileage))) mi"
        distanceForExpense = "\(Int(round(distanceInMileage)))"
        
        // Convert seconds to minutes
        let durationInMins: UInt = totalDurationInSeconds / 60
        
        let durationInHours: UInt = durationInMins / 60
        let durationInMinutes: UInt = durationInMins % 60
        let formatter = NumberFormatter()
        
        formatter.minimumIntegerDigits = 2
        
        let hourString = formatter.string(from: NSNumber(value: durationInHours))
        let minuteString = formatter.string(from: NSNumber(value: durationInMinutes))
        
        durationForExpense = hourString! + ":" + minuteString!
        calculatedDuration = Int(durationInMins)
        
        if durationInMins < 2 {
            
            totalDuration = "\(durationInMins) min"
            
        } else {
            
            totalDuration = "\(durationInMins) mins"
        }

        print("Calculate Duration")
        
        
        
        return Int(totalDurationInSeconds)
        
    }

}
