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
                fatalError("Saving error: \(error)")
            }
        }
    }
}


// MARK: Детальный способ инициализации стека (старый подход)
//final class LegacyCoreDataStack {
//    static let shared = LegacyCoreDataStack()
//
//    private init() {
//        setupCoreDataStack()
//    }
//
//    private(set) var context: NSManagedObjectContext!
//
//    // MARK: - Manual Stack Setup
//    private func setupCoreDataStack() {
//        // 1. Модель данных
//        guard let modelURL = Bundle.main.url(forResource: "Tracker", withExtension: "momd") else {
//            fatalError("Model file not found.")
//        }
//
//        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Cannot load model from \(modelURL)")
//        }
//
//        // 2. Persistent Store Coordinator
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
//
//        // 3. Указываем путь для базы данных (внутренняя папка Documents)
//        let fileManager = FileManager.default
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        let storeURL = urls[0].appendingPathComponent("Tracker.sqlite")
//
//        do {
//            try coordinator.addPersistentStore(
//                ofType: NSSQLiteStoreType,
//                configurationName: nil,
//                at: storeURL,
//                options: nil
//            )
//        } catch {
//            fatalError("Unable to add persistent store: \(error)")
//        }
//
//        // 4. Создаём контекст
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.persistentStoreCoordinator = coordinator
//        self.context = context
//    }
//
//    // MARK: - Save
//    func saveContext() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                fatalError("Saving error: \(error)")
//            }
//        }
//    }
//}
