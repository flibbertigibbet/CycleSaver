//
//  Trip+CoreDataProperties.swift
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

extension Trip {

    @NSManaged var start: NSDate?
    @NSManaged var stop: NSDate?
    @NSManaged var tripReadings: NSManagedObject?

}
