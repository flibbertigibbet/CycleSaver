//
//  ViewController.swift
//  CycleSaver
//
//  Created by Kathryn Killebrew on 11/7/15.
//  Copyright © 2015 Kathryn Killebrew. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var amRecording = false
    var currentTrip: Trip?
    
    var readingEntity: NSEntityDescription?
    var tripEntity: NSEntityDescription?
    
    lazy var manager = (UIApplication.sharedApplication().delegate as! AppDelegate).manager
    var managedContext: NSManagedObjectContext!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager?.delegate = self
        
        // start out centered on Philly City Hall
        let cityHall = CLLocation(latitude: 39.952460, longitude: -75.163323)
        let cityHallRegion = MKCoordinateRegionMakeWithDistance(cityHall.coordinate, 2000, 2000)
        mapView.setRegion(cityHallRegion, animated: false)
        
        // show and track user location
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        mapView.showsUserLocation = true
        
        
        if (managedContext == nil) {
            print("Have no managed context in viewDidLoad!")
        }
        
        tripEntity = NSEntityDescription.entityForName("Trip",
            inManagedObjectContext: managedContext)

        readingEntity = NSEntityDescription.entityForName("LocationReading",
            inManagedObjectContext: managedContext)
    }
    
    @IBAction func startStopButtonTapped(sender: UIButton) {

        amRecording = !amRecording
        
        if (amRecording) {
            sender.setTitle("Stop", forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.redColor()
            
            if CLLocationManager.locationServicesEnabled() {
                
                do {
                    currentTrip = Trip(entity: tripEntity!, insertIntoManagedObjectContext: managedContext)
                    currentTrip?.start = NSDate()
                    try managedContext.save()
                } catch let error as NSError {
                        print("Error: \(error) " + "description \(error.localizedDescription)")
                }
                
                manager?.startUpdatingLocation()
                print("stared recording")
            } else {
                // TODO: handle with message or prompt
                print("Location services not enabled!")
            }
            
        } else {
            sender.setTitle("Start", forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.greenColor()
            manager?.stopUpdatingLocation()
            print("stopped recording")
            
            do {
                currentTrip?.stop = NSDate()
                try managedContext.save()
                currentTrip = nil
            } catch let error as NSError {
                print("Error: \(error) " + "description \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        // potentially interesting things:
        /*
        newLocation.altitude
        newLocation.horizontalAccuracy // radius of uncertainty in meters
        newLocation.speed // instantaneous. m/s
        newLocation.timestamp
        newLocation.verticalAccuracy
        */
        
        print("new location: \(newLocation.coordinate)")
        
        do {
            
            let currentLocation = LocationReading(entity: readingEntity!, insertIntoManagedObjectContext: managedContext)
            
            currentLocation.latitude = newLocation.coordinate.latitude
            currentLocation.longitude = newLocation.coordinate.longitude
            currentLocation.altitude = newLocation.altitude
            currentLocation.horizontalAccuracy = newLocation.horizontalAccuracy
            currentLocation.speed = newLocation.speed
            currentLocation.timestamp = newLocation.timestamp
            
            try managedContext.save()
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
    }

}

