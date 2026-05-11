import CoreData

final class CoreDataStack: @unchecked Sendable {
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Task_Explorer")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var context: NSManagedObjectContext {
        container.viewContext
    }
}
