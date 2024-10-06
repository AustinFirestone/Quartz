import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Persistent Container
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Quartz")

        // Specify the CloudKit container ID
        let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "firstone.personal")
        let cloudStoreDescription = container.persistentStoreDescriptions.first
        cloudStoreDescription?.cloudKitContainerOptions = cloudKitContainerOptions

        if inMemory {
            cloudStoreDescription?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Context
    func saveContext() {
        let context = container.viewContext
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
