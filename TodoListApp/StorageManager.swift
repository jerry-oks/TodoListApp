//
//  StorageManager.swift
//  TodoListApp
//
//  Created by HOLY NADRUGANTIX on 26.09.2023.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    lazy var context = getContext()
    
    private init() {}
    
    private func getContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "TodoListAppStorage")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container.viewContext
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
