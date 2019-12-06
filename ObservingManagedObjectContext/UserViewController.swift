//
//  UserViewController.swift
//  ObservingManagedObjectContext
//
//  Created by Bart Jacobs on 24/07/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet var firstTextField: UITextField!
    @IBOutlet var lastTextField: UITextField!

    var user: User?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate Text Fields
        firstTextField.text = user?.first
        lastTextField.text = user?.last
    }

    // MARK: - Actions

    @IBAction func save(_ sender: UIButton) {
        // Update User
        user?.first = firstTextField.text
        user?.last = lastTextField.text

        // Dismiss View Controller
        dismiss(animated: true, completion: nil)
    }
    
}
