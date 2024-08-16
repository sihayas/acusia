//
//  CoreDataStack.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "acusia")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
