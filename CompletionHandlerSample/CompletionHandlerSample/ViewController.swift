//
//  ViewController.swift
//  CompletionHandlerSample
//
//  Created by Coty Embry on 1/15/16.
//  Copyright © 2016 cotyembry. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
//    var location = CLLocationManager()
    
    var lastLocation = CLLocation()
    var locationAuthorizationStatus:CLAuthorizationStatus!
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewdidappear")
        
        
        self.initLocationManager()
        
    }
    // Location Manager helper stuff
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }
    
    // Location Manager Delegate stuff
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
        print("location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("called locationManager didUpdateLocations")
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as! CLLocation
            var coord = locationObj.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!,  didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        //set the Core location delegate to self
        //location.delegate = self
        
        //get authorization to use the location //I should fix this later to check and make sure I actually go the authorization... too tired to keep messing with it right now though
/*        let returnedAuthorizationStatus = location.locationInstance.requestAlwaysAuthorization()
        if (returnedAuthorizationStatus == CLAuthorizationStatus.Restricted) || (returnedAuthorizationStatus == CLAuthorizationStatus.Denied) {
        }
*/
//        location.desiredAccuracy = kCLLocationAccuracyBest
        //location.requestLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("called locationManager didUpdateLocations")
    }
*/

}

