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

    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")

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
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: managedObjectContext)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: managedObjectContext)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserSegue" {
            if let userViewController = segue.destination as? UserViewController {
                userViewController.user = user
            }

        } else if segue.identifier == "AddNoteSegue" {
            if let addNoteViewController = segue.destination as? AddNoteViewController {
                addNoteViewController.user = user
            }
        }
    }

    // MARK: - Fetched Results Controller Delegate Methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell: cell, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        @unknown default:
            fatalError()
        }
    }

    // MARK: - Table View Data Source Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }

        return 0
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCell, for: indexPath)

        configureCell(cell: cell, atIndexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let note = fetchedResultsController.object(at: indexPath) as? Note {
            cell.textLabel?.text = note.title
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let note = fetchedResultsController.object(at: indexPath) as? NSManagedObject {
                // Delete Note
                managedObjectContext?.delete(note)
            }
        }
    }

    // MARK: - Notification Handling

    @objc func managedObjectContextObjectsDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !inserts.isEmpty {
            print("--- INSERTS ---")
            print(inserts)
            print("+++++++++++++++")
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updates.isEmpty {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
            print("+++++++++++++++")
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletes.isEmpty {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
    }

    @objc func managedObjectContextWillSave(notification: NSNotification) {

    }

    @objc func managedObjectContextDidSave(notification: NSNotification) {

    }

    // MARK: - Helper Methods

    private func fetchUser() -> User? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        do {
            if let result = try managedObjectContext?.fetch(fetchRequest) as? [User] , result.count > 0, let user = result.first {
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
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else { return nil }
        
        // Create User
        let result = User(entity: entity, insertInto: managedObjectContext)
        
        // Populate User
        result.first = "Bart"
        result.last = "Jacobs"
        
        return result
    }
    
}
