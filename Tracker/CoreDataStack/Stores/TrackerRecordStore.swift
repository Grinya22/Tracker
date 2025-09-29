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
        let normalizedDate = Calendar.current.startOfDay(for: record.date)
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            normalizedDate as NSDate
        )
        
        let records = try context.fetch(fetchRequest)
        
        if records.isEmpty {
            let object = TrackerRecordCoreData(context: context)
            object.id = record.id
            object.trackerId = record.trackerId
            object.date = normalizedDate
            
            if let tracker = try trackerStore.fetchTracker(by: record.trackerId) {
                object.tracker = tracker
            }
            
            CoreDataStack.shared.saveContext()
        } else {
            return
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            trackerId as CVarArg,
            normalizedDate as NSDate
        )
        
        let records = try context.fetch(fetchRequest)
        
        
        if !records.isEmpty {
            for record in records {
                context.delete(record)
            }
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func fetchAllRecords() throws -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        let objects = try context.fetch(fetchRequest)
        
        return objects.compactMap { object in
            guard let id = object.id,
                  let trackerId = object.trackerId,
                  let date = object.date else { return nil }
            
            return TrackerRecord(id: id, trackerId: trackerId, date: date)
        }
    }
}
