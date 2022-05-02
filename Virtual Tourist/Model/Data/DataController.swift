//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Dhara Bhavsar on 2022-03-22.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    //let backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
       //backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        //viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        //backgroundContext.automaticallyMergesChangesFromParent = true
        //backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    // save current context
    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    static let shared = DataController(modelName: "Virtual_Tourist")
}

// MARK: - Autosaving
extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        debugPrint("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
