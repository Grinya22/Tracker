import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
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
        
        // Преобразуем schedule в Data через трансформер
        //if let transformed = ScheduleValueTransformer().transformedValue(tracker.schedule) as? NSObject {
        //    object.schedule = transformed
        //}
        
        CoreDataStack.shared.saveContext()
    }
    
    
}

