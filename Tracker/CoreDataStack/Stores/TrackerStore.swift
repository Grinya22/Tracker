import UIKit
import CoreData

final class TrackerStore {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let object = TrackerCoreData(context: context)
        object.id = tracker.id
        object.name = tracker.name
        object.color = tracker.color
        object.emoji = tracker.emoji
        object.schedule = tracker.schedule as NSObject
        object.creationDate = tracker.creationDate
        
        object.category = category

        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(_ tracker: NSManagedObject) throws {
        context.delete(tracker)
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTrackers(for category: TrackerCategoryCoreData) throws {
        if let trackers = category.trackers as? Set<TrackerCoreData> {
            for tracker in trackers {
                context.delete(tracker)
            }
        }
        CoreDataStack.shared.saveContext()
    }
    
    func fetchTracker(by id: UUID) throws -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(request).first
    }

    func deleteTracker(by id: UUID) throws {
        if let obj = try fetchTracker(by: id) {
            context.delete(obj)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func updateTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) throws {
        guard let object = try fetchTracker(by: tracker.id) else {
            return
        }
        
        object.name = tracker.name
        object.color = tracker.color
        object.emoji = tracker.emoji
        object.schedule = tracker.schedule as NSObject
        object.creationDate = tracker.creationDate
        
        let catFetch = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        catFetch.fetchLimit = 1
        catFetch.predicate = NSPredicate(format: "title == %@", categoryTitle)

        if let newCategory = try context.fetch(catFetch).first {
            object.category = newCategory
        }
        
        CoreDataStack.shared.saveContext()
    }
}

