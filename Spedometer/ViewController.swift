//
//  ViewController.swift
//  Spedometer
//
//  Created by Jake Spann on 7/27/18.
//  Copyright © 2018 JakeSpann. All rights reserved.
//

import UIKit
import CoreLocation
var speedController = SpeedController()
var activityManager = MotionManager()

class ViewController: UIViewController {
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gaugeView: ABGaugeView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var colorIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Set up the speed manager
        speedController.delegate = self
        speedController.startTracking()
        
        // Do some things to make the UI look better
        speedLabel.layer.cornerRadius = speedLabel.frame.width/2
        speedLabel.layer.masksToBounds = true
        colorIndicatorView.layer.cornerRadius = 5
        colorIndicatorView.layer.masksToBounds = true
        
        // Set up the activity manager
        activityManager.delegate = self
        activityManager.beginTrackingActivity()
    }
    
    func activityTypeDidChange(to newActivity: userActivity) {
        // Iterate through each possible actity type for the new activity
        switch newActivity {
        case .automotive:
            print("Driving")
            activityImageView.image = UIImage(named: "CarIcon")?.withRenderingMode(.alwaysTemplate)
            speedController.locationManager?.activityType = .automotiveNavigation
            speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .cycling:
            print("Cycling")
            activityImageView.image = UIImage(named: "CyclingIcon")?.withRenderingMode(.alwaysTemplate)
            speedController.locationManager?.activityType = .fitness
            speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .running:
            print("Running")
            activityImageView.image = UIImage(named: "RunningIcon")?.withRenderingMode(.alwaysTemplate)
            speedController.locationManager?.activityType = .fitness
            speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .stationary:
            print("Stationary")
            activityImageView.image = UIImage()
            speedController.locationManager?.activityType = .fitness
            speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        case .unknown:
            print("Unknown")
            activityImageView.image = UIImage()
            speedController.locationManager?.activityType = .otherNavigation
           speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .walking:
            print("Walking")
            activityImageView.image = UIImage(named: "WalkingIcon")?.withRenderingMode(.alwaysTemplate)
            speedController.locationManager?.activityType = .fitness
            speedController.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
    }
    
    func speedDidUpdate(to mph: Double) {
        // Set the label to the rounded mph and set the needle to the exact mph
        speedLabel.text = String(Double(round(10*mph)/10))
        gaugeView.needleValue = CGFloat(mph)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

