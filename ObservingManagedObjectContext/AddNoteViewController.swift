//
//  AddNoteViewController.swift
//  ObservingManagedObjectContext
//
//  Created by Bart Jacobs on 24/07/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!

    var user: User!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if let managedObjectContext = user.managedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedObjectContext) {
            // Create Note
            let note = Note(entity: entity, insertInto: managedObjectContext)

            // Populate Note
            note.title = titleTextField.text
            note.content = contentTextView.text

            // Populate Relationship
            note.user = user
        }

        navigationController?.popViewController(animated: true)
    }
    
}
