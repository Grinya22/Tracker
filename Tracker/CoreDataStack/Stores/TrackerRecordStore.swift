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
}
