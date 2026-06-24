//
//  PersistenceController.swift
//  DriftDay
//
//  Wraps the Core Data stack. Single, local, on-device store — no CloudKit,
//  no App Groups, no shared containers.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DriftDay")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In a shipping app you'd surface this; for this scope we log loudly.
                assertionFailure("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    /// Deletes every record in the store. Used by "Clear All Data".
    func wipeAllData() {
        let entityNames = container.managedObjectModel.entities.compactMap { $0.name }
        for name in entityNames {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            delete.resultType = .resultTypeObjectIDs
            do {
                let result = try viewContext.execute(delete) as? NSBatchDeleteResult
                if let ids = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                        into: [viewContext]
                    )
                }
            } catch {
                assertionFailure("Failed to wipe \(name): \(error)")
            }
        }
        viewContext.reset()
    }
}
