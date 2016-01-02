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
    
    let drawIfWithinMeters = 100.0 // add to user-visible polyline points within this many meters of accuracy
    
    var amRecording = false
    var currentTrip: Trip?
    var lastLocation: CLLocation?
    var accruedDistance: Double = 0.0
    
    var readingEntity: NSEntityDescription?
    var tripEntity: NSEntityDescription?
    
    lazy var manager = (UIApplication.sharedApplication().delegate as! AppDelegate).manager
    lazy var coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    var managedContext: NSManagedObjectContext!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager?.delegate = self
        
        // start out centered on Philly City Hall
        let cityHall = CLLocation(latitude: 39.952460, longitude: -75.163323)
        let cityHallRegion = MKCoordinateRegionMakeWithDistance(cityHall.coordinate, 2000, 2000)
        mapView.setRegion(cityHallRegion, animated: false)
        
        // show and track user location
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        mapView.showsUserLocation = true
        
        
        managedContext = coreDataStack.context
        if (managedContext == nil) {
            print("Have no core data context in viewDidLoad!")
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
                
                currentTrip = Trip(entity: tripEntity!, insertIntoManagedObjectContext: managedContext)
                currentTrip?.start = NSDate()
                coreDataStack.saveContext()
                
                manager?.startUpdatingLocation()
                print("started recording")
            } else {
                // TODO: handle with message or prompt
                print("Location services not enabled!")
            }
            
        } else {
            sender.setTitle("Start", forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.greenColor()
            manager?.stopUpdatingLocation()
            print("stopped recording")
            
            currentTrip?.stop = NSDate()
            currentTrip?.distance = accruedDistance
            coreDataStack.saveContext()
            currentTrip = nil
            lastLocation = nil
            accruedDistance = 0.0
            mapView.removeOverlays(mapView.overlays)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("new location: \(newLocation.coordinate)")
        
        guard let trip = currentTrip
            else {
                print("No trip to hold coordinates")
                return
        }
        
        // draw line from last location to this and increment distance
        if (newLocation.horizontalAccuracy < drawIfWithinMeters) {
            if let last = lastLocation {
                accruedDistance += newLocation.distanceFromLocation(last)
                var coords = [last.coordinate, newLocation.coordinate]
                let polyline = MKPolyline(coordinates: &coords, count: coords.count)
                mapView.addOverlay(polyline)
            }
            lastLocation = newLocation
        }
        
        // save to CoreData
        let currentLocation = LocationReading(entity: readingEntity!, insertIntoManagedObjectContext: managedContext)
        currentLocation.readingTrip = trip;
        
        currentLocation.latitude = newLocation.coordinate.latitude
        currentLocation.longitude = newLocation.coordinate.longitude
        currentLocation.altitude = newLocation.altitude
        currentLocation.horizontalAccuracy = newLocation.horizontalAccuracy
        currentLocation.speed = newLocation.speed
        currentLocation.timestamp = newLocation.timestamp
        
        coreDataStack.saveContext()
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKindOfClass(MKPolyline) {
            return MKOverlayRenderer()
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}

