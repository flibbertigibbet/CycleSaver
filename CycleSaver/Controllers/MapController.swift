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
    
    // constants
    let drawIfWithinMeters = 100.0 // add to user-visible polyline points within this many meters of accuracy
    
    // start out centered on Philly City Hall
    let originPoint = CLLocation(latitude: 39.952460, longitude: -75.163323)
    
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
        
        manager?.allowsBackgroundLocationUpdates = true
        
        // defer for meters / seconds
        manager?.allowDeferredLocationUpdatesUntilTraveled(50, timeout: 10)
        
        let originRegion = MKCoordinateRegionMakeWithDistance(originPoint.coordinate, 2000, 2000)
        mapView.setRegion(originRegion, animated: false)
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (amRecording) {
            print("Back to foreground; resume updates")
            manager?.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("TODO: Going to background; stop visible updates")
        manager?.stopUpdatingLocation()
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
                
                if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    manager?.startMonitoringSignificantLocationChanges()
                }
                
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
            manager?.stopMonitoringSignificantLocationChanges()
            
            print("stopped recording")
            
            currentTrip?.stop = NSDate()
            currentTrip?.distance = accruedDistance
            coreDataStack.saveContext()
            
            // reset state
            currentTrip = nil
            lastLocation = nil
            accruedDistance = 0.0
            mapView.removeOverlays(mapView.overlays)
        }
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Authorization status changed for location updates")
        
        let locationPermissions = CLLocationManager.authorizationStatus()
        
        switch locationPermissions {
        case .Authorized:
            print("Authorized")
        case .Denied:
            print("Denied location update permission")
            handleLocationPermissionDenial()
        case .NotDetermined:
            // should not need to happen here, as app delegate already asked
            manager.requestAlwaysAuthorization()
        case .Restricted:
            print("Denied location update permission")
            handleLocationPermissionDenial()
        default:
            break
        }
    }
    
    func handleLocationPermissionDenial() {
        // TODO: show a useful message, then exit
        print("TODO: show useful message before exiting")
        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got \(locations.count) deferred location updates")
        
        guard let trip = currentTrip
            else {
                print("No trip to hold coordinates")
                return
        }
        
        var coords = [CLLocationCoordinate2D]()
        if let last = lastLocation {
            coords.append(last.coordinate)
        }
        
        for newLocation in locations {
            if (newLocation.horizontalAccuracy < drawIfWithinMeters) {
                if let last = lastLocation {
                    accruedDistance += newLocation.distanceFromLocation(last)
                    coords.append(newLocation.coordinate)
                    
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
        }
        
        coreDataStack.saveContext()
        
        let polyline = MKPolyline(coordinates: &coords, count: coords.count)
        mapView.addOverlay(polyline)
    }
}

