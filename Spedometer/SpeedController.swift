//
//  SpeedController.swift
//  Spedometer
//
//  Created by Jake Spann on 7/27/18.
//  Copyright © 2018 JakeSpann. All rights reserved.
//

import Foundation

import CoreLocation
import CoreMotion

//typealias Speed = CLLocationSpeed // We don't need this

class SpeedController: NSObject, CLLocationManagerDelegate {
    
    var delegate: ViewController?
     var locationManager: CLLocationManager?
    
    func startTracking() {
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager.locationServicesEnabled() ? CLLocationManager() : nil
        
        // By default, we want no distance filter, and we're assuming automotive navigation is occuring. The activityType can change based upon the user's activity.
            
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager?.distanceFilter = kCLDistanceFilterNone
        self.locationManager?.activityType = .automotiveNavigation
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
                self.locationManager?.requestWhenInUseAuthorization()
            } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
                print("updatingLocation")
                self.locationManager?.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse { // After authorizing location access for the app, make sure that authorization for either "always" or "when in use" was selected.
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationDidUpdate")
        if locations.count > 0 {
            let kmph = max(locations[locations.count - 1].speed / 1000 * 3600, 0);
            delegate?.speedDidUpdate(to: kmph * 0.621371); // Convert the kmph to mph and inform the ViewController of the speed change
        }
    }
    
    
}

class MotionManager: CMMotionActivityManager {
    var delegate = ViewController()
    
    func beginTrackingActivity() {
        self.queryActivityStarting(from: Date(), to: Date(), to: .main) { motionActivities, error in
            
            var hcActivities = [CMMotionActivity()]
            motionActivities?.forEach { activity in
                // only interested in activities that were of at least medium confidence
                if activity.confidence == .medium || activity.confidence == .high {
                   hcActivities.append(activity)
                }}
            
            let bestActivity = hcActivities.max(by: { (a, b) -> Bool in
                return Float(a.confidence.rawValue) < Float(b.confidence.rawValue)
            })
            
            // The if statments below check to see which type of activity the best activity is, then informs the ViewController
            if (bestActivity?.unknown)! {
                self.delegate.activityTypeDidChange(to: .unknown)
            }
            
            if (bestActivity?.stationary)! {
                self.delegate.activityTypeDidChange(to: .stationary)
            }
            
            if (bestActivity?.walking)! {
                self.delegate.activityTypeDidChange(to: .walking)
            }
            
            if (bestActivity?.running)! {
                self.delegate.activityTypeDidChange(to: .running)
            }
            
            if (bestActivity?.automotive)! {
                self.delegate.activityTypeDidChange(to: .automotive)
            }
            
            if (bestActivity?.cycling)! {
                self.delegate.activityTypeDidChange(to: .cycling)
            }
            
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
    }
    }
}

enum userActivity {
    case unknown
    case stationary
    case walking
    case running
    case automotive
    case cycling
}
