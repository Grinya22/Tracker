import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addCategory(_ title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        
        CoreDataStack.shared.saveContext()
        
        return category
    }
    
    func fetchCategories() throws -> [TrackerCategoryCoreData] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories
        } catch {
            return []
        }
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        CoreDataStack.shared.saveContext()
    }
}
