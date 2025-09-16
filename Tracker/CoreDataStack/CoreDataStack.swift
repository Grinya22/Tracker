import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        
        // Создаём URL для SQLite-файла
        guard let documentsDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Не удалось найти Application Support directory")
        }
        let storeURL = documentsDirectory.appendingPathComponent("Tracker.sqlite")
        
        // Настраиваем description
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        print("Persistent Store URL: \(storeURL)")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Ошибка загрузки хранилища: \(error), \(error.userInfo)")
                if error.code == 134140 { // Ошибка миграции
                    print("Попытка удалить старое хранилище...")
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        print("Старое хранилище удалено, перезапуск загрузки...")
                        // Повторная попытка загрузки
                        container.loadPersistentStores { _, newError in
                            if let newError = newError as NSError? {
                                fatalError("Не удалось загрузить хранилище после удаления: \(newError), \(newError.userInfo)")
                            } else {
                                print("Хранилище успешно загружено после удаления: \(storeDescription)")
                            }
                        }
                    } catch {
                        fatalError("Не удалось удалить старое хранилище: \(error)")
                    }
                } else {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            } else {
                print("Хранилище успешно загружено: \(storeDescription)")
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
                print("CoreData: Сохранение успешно в \(persistentContainer.persistentStoreDescriptions.first?.url?.path ?? "unknown")")
            } catch {
                print("CoreData: Ошибка сохранения: \(error.localizedDescription)")
            }
        } else {
            print("CoreData: Нет изменений для сохранения. контекст уже чистый - так сказал гпт")

        }
    }
}
