import SwiftUI
import CoreData

class DataManager {
    static let shared = DataManager()

    // Persistent container
    let persistentContainer: NSPersistentCloudKitContainer

    init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "Quartz")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Fetch Subjects with Batch Fetching
    func fetchSubjects(batchSize: Int = 20) -> [SubjectEntity] {
        let request: NSFetchRequest<SubjectEntity> = SubjectEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SubjectEntity.name, ascending: true)]
        request.fetchBatchSize = batchSize // Limit the number of results fetched at a time

        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Failed to fetch subjects: \(error)")
            return []
        }
    }

    // MARK: - Add Subject
    func addSubject(name: String) {
        let newSubject = SubjectEntity(context: persistentContainer.viewContext)
        newSubject.id = UUID()
        newSubject.name = name

        saveContext()
    }

    // MARK: - Delete Subject
    func deleteSubject(_ subject: SubjectEntity) {
        persistentContainer.viewContext.delete(subject)
        saveContext()
    }

    // MARK: - Add Time Session to a Subject
    func addTimeSession(to subject: SubjectEntity, startTime: Date, endTime: Date) {
        let newSession = TimeSessionEntity(context: persistentContainer.viewContext)
        newSession.id = UUID()
        newSession.startTime = startTime
        newSession.endTime = endTime
        newSession.subject = subject

        saveContext()
    }

    // MARK: - Fetch Time Sessions Lazily for a Subject
    func fetchTimeSessions(for subject: SubjectEntity, batchSize: Int = 20) -> [TimeSessionEntity] {
        let request: NSFetchRequest<TimeSessionEntity> = TimeSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "subject == %@", subject)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TimeSessionEntity.startTime, ascending: true)]
        request.fetchBatchSize = batchSize

        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Failed to fetch time sessions: \(error)")
            return []
        }
    }

    // MARK: - Delete Time Session
    func deleteTimeSession(_ session: TimeSessionEntity) {
        persistentContainer.viewContext.delete(session)
        saveContext()
    }

    // MARK: - Fetch All Time Sessions with Batch Fetching (optional)
    func fetchAllTimeSessions(batchSize: Int = 20) -> [TimeSessionEntity] {
        let request: NSFetchRequest<TimeSessionEntity> = TimeSessionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TimeSessionEntity.startTime, ascending: true)]
        request.fetchBatchSize = batchSize

        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Failed to fetch time sessions: \(error)")
            return []
        }
    }
}
