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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
    }
    
}