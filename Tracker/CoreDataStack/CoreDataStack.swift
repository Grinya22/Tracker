import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker") // Имя .xcdatamodeld файла
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Здесь можно добавить логирование или алерт
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback() // Если что-то пошло не так, то мы просто "откатываем" все изменения назад
            }
        }
    }
}
