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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "title",
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
}

// MARK: - TrackerDataProviderProtocol

extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        // Возвращаем количество секций (каждая секция — одна категория).
        // Если секций нет, возвращаем 0 (было 1, что могло вызывать ошибки).
        // Зачем: Предотвращает попытку доступа к несуществующим секциям.
        // Почему так: Если нет категорий, таблица должна быть пустой.
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        // Возвращает количество трекеров в категории, извлекая их из отношения trackers
        // Проверяем, что секция валидна.
        guard section < fetchedResultsController.sections?.count ?? 0,
              let sectionInfo = fetchedResultsController.sections?[section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData] else {
                  return 0
        }
        // Возвращаем количество трекеров в категории.
        // Зачем: Каждая строка в секции — это трекер, как в твоей исходной логике.
        // Почему так: Проверки предотвращают краш, если секция или категория недоступны (например, после удаления).
        return trackers.count
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        // Извлекает трекер из отношения trackers категории и преобразует его в модель Tracker
        guard indexPath.section < fetchedResultsController.sections?.count ?? 0,
              let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData],
              indexPath.row < trackers.count else {
                  return nil
        }
        
        let trackerObject = trackers[indexPath.row]
                
        // Возвращаем объект Tracker, созданный из TrackerCoreData.
        // Зачем: Для отображения трекера в ячейке таблицы.
        // Почему так: Проверки индексов предотвращают краш, если трекер недоступен.
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
        // Возвращает название категории для заголовка секции
        // Проверяем валидность секции.
        guard section < fetchedResultsController.sections?.count ?? 0,
              let sectionInfo = fetchedResultsController.sections?[section] else {
                  return nil
        }
        // Возвращаем название секции (название категории).
        // Зачем: Для отображения заголовка секции в таблице.
        // Почему так: sectionInfo.name уже содержит title категории из sectionNameKeyPath.
        return sectionInfo.name
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
        try trackerStore.addTracker(tracker)
        
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
