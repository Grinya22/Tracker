import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let object = TrackerRecordCoreData(context: context)
        object.id = record.id
        object.data = record.data
        
        if let tracker = try trackerStore.fetchTracker(by: record.id) {
            object.tracker = tracker
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND data == %@", trackerId as CVarArg, date as NSDate)
        let records = try context.fetch(fetchRequest)
        
        if let record = records.first {
            context.delete(record)
            CoreDataStack.shared.saveContext()
        }
    }
}
