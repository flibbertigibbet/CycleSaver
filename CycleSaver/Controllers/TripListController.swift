//
//  TripListController.swift
//  CycleSaver
//
//  Created by Kathryn Killebrew on 12/5/15.
//  Copyright © 2015 Kathryn Killebrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let tripCellIdentifier = "tripCellReuseIdentifier"


class TripListController: UIViewController {
    
    @IBOutlet weak var tripTableView: UITableView!
    
    var fetchedResultsController : NSFetchedResultsController!
    var coreDataStack: CoreDataStack!
    let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        
        let startSort = NSSortDescriptor(key: "start", ascending: true)
        let stopSort = NSSortDescriptor(key: "stop", ascending: true)

        fetchRequest.sortDescriptors = [startSort, stopSort]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            tripTableView.reloadData()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func configureCell(cell: TripCell, indexPath: NSIndexPath) {
        let trip = fetchedResultsController.objectAtIndexPath(indexPath) as! Trip
        
        if let tripStart = trip.start {
            cell.startLabel.text = formatter.stringFromDate(tripStart)
        }
        
        if let tripStop = trip.stop {
            cell.stopLabel.text = formatter.stringFromDate(tripStop)
        }
        
        cell.coordsCount.text = "???"
        // TODO: how to get related obj
    }
    
}

extension TripListController: UITableViewDataSource {
    
    func numberOfSectionsInTableView (tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        let sectionInfo =
        fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tripCellIdentifier, forIndexPath: indexPath) as! TripCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
}

extension TripListController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let trip = fetchedResultsController.objectAtIndexPath(indexPath) as! Trip
        // TODO: make this trigger
        print("Selected trip that started at \(trip.start).")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // delete from data source here; this will then trigger deletion on the NSFetchedResultsControllerDelegate, which updates the view
            let trip = fetchedResultsController.objectAtIndexPath(indexPath) as! Trip
            coreDataStack.context.deleteObject(trip)
            coreDataStack.saveContext()
        default: break
        }
    }
}

extension TripListController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tripTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tripTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tripTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tripTableView.cellForRowAtIndexPath(indexPath!) as! TripCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tripTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tripTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tripTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int,forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
            case .Insert:
                tripTableView.insertSections(indexSet, withRowAnimation: .Automatic)
            case .Delete:
                tripTableView.deleteSections(indexSet, withRowAnimation: .Automatic)
            default :
                break
        }
    }
}


