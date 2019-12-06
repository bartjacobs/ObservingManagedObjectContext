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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataManager.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataManager.saveContext()
    }

}
