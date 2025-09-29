import UIKit
import CoreData

// MARK: - TrackerStoreUpdate

struct TrackerStoreUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

// MARK: - TrackerDataProviderDelegate

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func setFilter(_ filter: FilterType)
}

// MARK: - TrackerDataProviderProtocol

protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ secion: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func categoryTitle(forSection section: Int) -> String?
    func addTracker(_ tracker: Tracker, to category: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
    var delegate: TrackerDataProviderDelegate? { get set }
}

// MARK: - TrackerDataProvider

final class TrackerDataProvider: NSObject {
    
    let context: NSManagedObjectContext
    
    weak var delegate: TrackerDataProviderDelegate?
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var insertedSections: IndexSet = []
    private var deletedSections: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )

        controller.delegate = self
        try? controller.performFetch()

        return controller
    }()
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) throws {
        self.context = trackerStore.context
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init()
    }
    
    func searchTrackers(with text: String, completion: @escaping ([TrackerCategory]) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreDataForSearchTrackers")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            if !text.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", text)
            }
            
            do {
                let results = try self.context.fetch(fetchRequest)
                
                var categoriesDict: [String: [Tracker]] = [:]
                
                for obj in results {
                    let tracker = Tracker(
                        id: obj.id ?? UUID(),
                        name: obj.name ?? "",
                        color: obj.color as? UIColor ?? .ypWhite,
                        emoji: obj.emoji ?? "",
                        schedule: (obj.schedule as? [WeekDay]) ?? [],
                        creationDate: obj.creationDate ?? Date()
                    )
                    
                    let categoryTitle = obj.category?.title ?? "Без категории"
                    categoriesDict[categoryTitle, default: []].append(tracker)
                }
                
                let categories = categoriesDict.map { TrackerCategory(title: $0.key, trackers: $0.value) }
                
                DispatchQueue.main.async {
                    completion(categories)
                }
            } catch {
                print("Ошибка поиска: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func setFilter(_ filter: FilterType) {
        let fetchRequest = fetchedResultsController.fetchRequest
        
        let date: Date
        
        switch filter {
        case .all:
            date = Date()
        case .today(let myDate), .completed(let myDate), .uncompleted(let myDate):
            date = myDate
        }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        
        let schedulePredicate = NSPredicate(format: "ANY schedule.rawValue == %d", adjustedWeekday)
        
        let startOfDay = Calendar.current.startOfDay(for: date) as NSDate
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay as Date)! as NSDate
        
        switch filter {
        case .all:
            fetchRequest.predicate = nil
            
        case .today:
            fetchRequest.predicate = nil
            
        case .completed:
            let completedPredicate = NSPredicate(format: "SUBQUERY(records, $r, $r.date >= %@ AND $r.date < %@).@count > 0", startOfDay, endOfDay)
            fetchRequest.predicate = completedPredicate
            
        case .uncompleted:
            let uncompletedPredicate = NSPredicate(format: "SUBQUERY(records, $r, $r.date >= %@ AND $r.date < %@).@count == 0", startOfDay, endOfDay)
            fetchRequest.predicate = uncompletedPredicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            let trackers = try context.fetch(fetchRequest)
            
            // Уведомляем делегата об изменении фильтра
            delegate?.setFilter(filter)
        } catch {
            print("Ошибка при выборке: \(error)")
        }
    }
}

// MARK: - TrackerDataProviderProtocol

extension TrackerDataProvider: TrackerDataProviderProtocol {    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerObject = fetchedResultsController.object(at: indexPath)
        return Tracker(
            id: trackerObject.id ?? UUID(),
            name: trackerObject.name ?? "",
            color: trackerObject.color as? UIColor ?? .ypWhite,
            emoji: trackerObject.emoji ?? "",
            schedule: (trackerObject.schedule as? [WeekDay]) ?? [],
            creationDate: trackerObject.creationDate ?? Date()
        )
    }
    
    func categoryTitle(forSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        // Добавляет трекер и связывает его с категорией, проверяя, существует ли категория, или создавая новую
        // Ищем категорию по названию.
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        let categories = try context.fetch(fetchRequest)

        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            // Создаём новую категорию, если не нашли.
            category = try categoryStore.addCategory(categoryTitle)
        }
        
        // Добавляем трекер и связываем с категорией.
        try trackerStore.addTracker(tracker, to: category)

        // Сохраняем изменения.
        // Зачем: Чтобы трекер появился в Core Data и таблице.
        // Почему так: Используем обновлённый addTracker, чтобы корректно установить связь.
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        // Извлекает трекер из категории по indexPath и удаляет его
        guard indexPath.section < fetchedResultsController.sections?.count ?? 0,
              let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData],
              indexPath.row < trackers.count else {
                  return
        }
        
        let tracker = trackers[indexPath.row]
        // Удаляем трекер.
        // Зачем: Для удаления трекера из категории.
        // Почему так: Проверки предотвращают попытку удаления несуществующего трекера.
        try trackerStore.deleteTracker(tracker)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    /* 1:   Метод controllerWillChangeContent срабатывает перед тем, как
            изменится состояние объектов, которые добавляются или удаляются.
            В нём мы инициализируем переменные, которые содержат индексы
            изменённых объектов. */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Очищаем массивы перед обработкой изменений.
        // Зачем: Чтобы начать сбор новых изменений с чистого листа.
        // Почему так: Предотвращает накопление старых данных.
        insertedIndexes = []
        deletedIndexes = []
        insertedSections = []
        deletedSections = []
    }
    
    /* 2:   Метод controllerDidChangeContent срабатывает после
            добавления или удаления объектов. В нём мы передаём индексы
            изменённых объектов в класс MainViewController и очищаем до следующего изменения
            переменные, которые содержат индексы. */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата об изменениях.
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        ))
        
        insertedIndexes = []
        deletedIndexes = []
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        // Обрабатываем вставку или удаление секций.
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
        // Зачем: Чтобы таблица обновляла секции при добавлении/удалении категорий.
        // Почему так: NSFetchedResultsController сообщает об изменениях секций.
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.append(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .update, .move:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
            
            if let newIndexPath = newIndexPath {
                insertedIndexes.append(newIndexPath)
            }
        @unknown default:
            break
        }
        
        // Зачем: Чтобы таблица обновляла строки при добавлении/удалении трекеров.
        // Почему так: NSFetchedResultsController сообщает об изменениях объектов.
    }
}
