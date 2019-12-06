//
//  Note+CoreDataProperties.swift
//  ObservingManagedObjectContext
//
//  Created by Bart Jacobs on 24/07/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var content: String?
    @NSManaged var title: String?
    @NSManaged var createdAt: TimeInterval
    @NSManaged var updatedAt: TimeInterval
    @NSManaged var user: User?

}
