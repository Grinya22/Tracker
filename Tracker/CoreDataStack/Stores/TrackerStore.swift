import UIKit
import CoreData

final class TrackerStore {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let object = TrackerCoreData(context: context)
        object.id = tracker.id
        object.name = tracker.name
        object.color = tracker.color
        object.emoji = tracker.emoji
        object.schedule = tracker.schedule as NSObject
        object.creationDate = tracker.creationDate
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(_ tracker: NSManagedObject) throws {
        context.delete(tracker)
        CoreDataStack.shared.saveContext()
    }
}

