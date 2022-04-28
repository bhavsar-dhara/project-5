//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-14.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "Virtual_Tourist")
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(0.0, forKey: "Latitude")
            UserDefaults.standard.set(0.0, forKey: "Longitude")
            UserDefaults.standard.synchronize()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapview = navigationController.topViewController as! TravelLocationMapViewController
        mapview.dataController = (UIApplication.shared.delegate as? AppDelegate)?.dataController
        
//        checkIfFirstLaunch()
        print("App Delegate: will finish launching")
        print("Documents Directory: ", FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last ?? "Not Found!")
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

