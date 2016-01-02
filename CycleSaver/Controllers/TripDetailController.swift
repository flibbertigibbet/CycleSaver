//
//  TripDetailController.swift
//  CycleSaver
//
//  Created by Kathryn Killebrew on 12/8/15.
//  Copyright © 2015 Kathryn Killebrew. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import UIKit

class TripDetailController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var trip: Trip!
    var coreDataStack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        var fetchRequest: NSFetchRequest!
        var readings: [LocationReading];
        
        let model = coreDataStack.context.persistentStoreCoordinator!.managedObjectModel
        
        let filterForTrip: NSPredicate = NSPredicate(format: "ANY readingTrip == %@", trip)
        
        fetchRequest = model.fetchRequestTemplateForName("FetchTripCoords")
        fetchRequest = fetchRequest.copy() as! NSFetchRequest
        fetchRequest.predicate = filterForTrip
        
        do {
            if (trip.tripReadings!.count == 0) {
                print("No readings to display for trip!")
                return
            }
            
            readings = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [LocationReading]
            
            print("Total trip readings: \(trip.tripReadings!.count)");
            print("Using \(readings.count) readings with accuracy > 70%")
            
            
            var coords: [CLLocationCoordinate2D] = []
            for reading in readings {
                let coord = CLLocationCoordinate2D(latitude: reading.latitude as Double!, longitude: reading.longitude as Double!)
                coords.append(coord)
            }
            
            let polyline = MKPolyline(coordinates: &coords, count: coords.count)
            mapView.addOverlay(polyline)
            
            mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKindOfClass(MKPolyline) {
            print("Hey, that's not a polyline.")
            return MKOverlayRenderer()
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.greenColor()
        renderer.lineWidth = 3
        return renderer
    }
    
}