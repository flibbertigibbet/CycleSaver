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
        manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //manager?.allowsBackgroundLocationUpdates = true
        //manager?.allowDeferredLocationUpdatesUntilTraveled(<#T##distance: CLLocationDistance##CLLocationDistance#>, timeout: <#T##NSTimeInterval#>)
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }
}

