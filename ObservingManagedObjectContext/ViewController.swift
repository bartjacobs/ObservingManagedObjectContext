//
//  ViewController.swift
//  ObservingManagedObjectContext
//
//  Created by Bart Jacobs on 24/07/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let noteCell = "NoteCell"

    @IBOutlet var titleTextField: UITextField!

    var user: User?
    var managedObjectContext: NSManagedObjectContext?

    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Note")

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        // Initialize Fetched Results Controller
        var frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        frc.delegate = self

        return frc
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let managedObjectContext = managedObjectContext {
            // Add Observer
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
        }

        if let currentUser = fetchUser() {
            user = currentUser

        } else if let newUser = createUser() {
            user = newUser
        }

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError

            print("Unable to Perform Fetch")
            print(fetchError, fetchError.localizedDescription)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserSegue" {
            if let userViewController = segue.destinationViewController as? UserViewController {
                userViewController.user = user
            }

        } else if segue.identifier == "AddNoteSegue" {
            if let addNoteViewController = segue.destinationViewController as? AddNoteViewController {
                addNoteViewController.user = user
            }
        }
    }

    // MARK: - Fetched Results Controller Delegate Methods

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }

    // MARK: - Table View Data Source Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }

        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }

        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(noteCell, forIndexPath: indexPath)

        configureCell(cell, atIndexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
            cell.textLabel?.text = note.title
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
                // Delete Note
                managedObjectContext?.deleteObject(note)
            }
        }
    }

    // MARK: - Notification Handling

    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> where inserts.count > 0 {
            print("--- INSERTS ---")
            print(inserts)
            print("+++++++++++++++")
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> where updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
            print("+++++++++++++++")
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> where deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
    }

    func managedObjectContextWillSave(notification: NSNotification) {

    }

    func managedObjectContextDidSave(notification: NSNotification) {

    }

    // MARK: - Helper Methods

    private func fetchUser() -> User? {
        let fetchRequest = NSFetchRequest(entityName: "User")

        do {
            if let result = try managedObjectContext?.executeFetchRequest(fetchRequest) as? [User] where result.count > 0, let user = result.first {
                return user
            }

        } catch {
            let fetchError = error as NSError

            print("Unable to Fetch User")
            print(fetchError, fetchError.localizedDescription)
        }

        return nil
    }

    private func createUser() -> User? {
        guard let managedObjectContext = managedObjectContext,
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext) else { return nil }
        
        // Create User
        let result = User(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
        
        // Populate User
        result.first = "Bart"
        result.last = "Jacobs"
        
        return result
    }
    
}
