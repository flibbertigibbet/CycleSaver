//
//  AppDelegate.swift
//  CycleSaver
//
//  Created by Kathryn Killebrew on 11/7/15.
//  Copyright © 2015 Kathryn Killebrew. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var manager: CLLocationManager?
    
    lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        manager = CLLocationManager()
        manager?.requestAlwaysAuthorization()

        // must be 'best' with no distance filter for update deferral to work
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.distanceFilter = kCLDistanceFilterNone
        
        manager?.pausesLocationUpdatesAutomatically = false
        manager?.activityType = CLActivityType.Fitness
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        coreDataStack.saveContext()
        print("Going away")
        manager?.stopUpdatingLocation()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
        print("Bye!")
        manager?.stopUpdatingLocation()
    }
}

