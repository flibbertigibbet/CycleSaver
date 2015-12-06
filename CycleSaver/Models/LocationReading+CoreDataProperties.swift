//
//  LocationReading+CoreDataProperties.swift
//  CycleSaver
//
//  Created by Kathryn Killebrew on 12/5/15.
//  Copyright © 2015 Kathryn Killebrew. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LocationReading {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var altitude: NSNumber?
    @NSManaged var speed: NSNumber?
    @NSManaged var horizontalAccuracy: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var readingTrip: NSOrderedSet?

}
