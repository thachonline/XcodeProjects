//
//  CoreDataStack.swift
//  EventsCountdown
//
//  Created by Bondar Yaroslav on 7/26/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit
import CoreData


//typealias ManagedObjectSaveStatusHandler = (ManagedObjectSaveStatus) -> Void
//
//enum ManagedObjectSaveStatus {
//    case saved
//    case error(Error)
//}

/// pass "*.xcdatamodeld" name 
/// in "private lazy var persistentContainer: NSPersistentContainer"
/// and "private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator?"
final class CoreDataStack: NSObject {
    
    private override init() {
        super.init()
        
        if #available(iOS 10.0, *) {
            mainContext.automaticallyMergesChangesFromParent = true
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
        }
        
        /// for tests
        //NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func managedObjectContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }
        if context != mainContext, context.parent == mainContext {
            /// will be called on background queue
            mainContext.saveAsync()
        }
    }
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EventsCountdown")
        container.loadPersistentStores { (storeDescription, error) in
            print("CoreData: Inited \(storeDescription)")
            if let error = error {
                print("CoreData: Unresolved error \(error)")
                return
            }
        }
        return container
    }()
    
    ///--- available iOS 9
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(name: "EventsCountdown")
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    ///---
    
    // MARK: Public methods
    
    static let shared = CoreDataStack()
    
    var newBackgroundContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            /// don't set parent for newBackgroundContext(), it will crash
            /// with error "Context already has a coordinator; cannot replace"
            return persistentContainer.newBackgroundContext()
        } else {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = mainContext
            return context
        }
        /// for tests
//        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        context.parent = mainContext
//        return context
    }
    
    var mainContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return persistentContainer.viewContext
        } else {
            return managedObjectContext
        }
    }
    
    /// for background fetch
    //lazy var backgroundContext = newBackgroundContext
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        if #available(iOS 10.0, *) {
            persistentContainer.performBackgroundTask(block)
        } else {
            let context = newBackgroundContext
            context.perform { 
                block(context)
            }
        }
    }
}


/// iOS 10 fetchRequest.execute() test
//func execute2 <T>(fetchRequest: NSFetchRequest<T>) {
//    let context = CoreDataStack.shared.backgroundContext
//    context.perform {
//        if #available(iOS 10.0, *) {
//            let q = try? fetchRequest.execute()
//            print("---", q?.count)
//        } else {
//            let q = try? context.fetch(fetchRequest)
//            print("---", q?.count)
//        }
//    }
//}

