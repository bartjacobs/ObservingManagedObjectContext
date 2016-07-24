//
//  AppDelegate.swift
//  ObservingManagedObjectContext
//
//  Created by Bart Jacobs on 24/07/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coreDataManager = CoreDataManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? ViewController {
            // Configure View Controller
            viewController.managedObjectContext = coreDataManager.managedObjectContext

            // Set Root View Controller
            window?.rootViewController = navigationController
        }

        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        coreDataManager.saveContext()
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataManager.saveContext()
    }

}
