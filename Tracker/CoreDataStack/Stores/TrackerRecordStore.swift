import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let object = TrackerRecordCoreData(context: context)
        object.id = record.id
        object.data = record.data
        
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
