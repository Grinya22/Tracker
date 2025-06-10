import UIKit
import CoreData


// MARK: - TrackerStoreUpdate

struct TrackerStoreUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
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
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        // Возвращает количество трекеров в категории, извлекая их из отношения trackers
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        let trackers = (sectionInfo.objects as? [TrackerCategoryCoreData])?.first?.trackers?.allObjects as? [TrackerCoreData]
        return trackers?.count ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        // Извлекает трекер из отношения trackers категории и преобразует его в модель Tracker
        guard let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData],
              indexPath.item < trackers.count else {
            return nil
        }
        
        let trackerObject = trackers[indexPath.item]
                
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
        fetchedResultsController.sections?[section].name
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        // Добавляет трекер и связывает его с категорией, проверяя, существует ли категория, или создавая новую
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        let categories = try context.fetch(fetchRequest)
        
        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = categoryTitle
        }
        
        try trackerStore.addTracker(tracker)
        
        let trackerFetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerObject = try context.fetch(trackerFetchRequest).first {
            category.addToTrackers(trackerObject)
            
            if let sectionIndex = fetchedResultsController.sections?.firstIndex(where: { $0.name == categoryTitle }) {
                let trackersCount = numberOfRowsInSection(sectionIndex)
                insertedIndexes.append(IndexPath(item: trackersCount - 1, section: sectionIndex))
            }
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        // Извлекает трекер из категории по indexPath и удаляет его
        guard let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData],
              indexPath.item < trackers.count else {
            return
        }
        
        let trackerObject = trackers[indexPath.item]
        try trackerStore.deleteTracker(trackerObject)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    /* 1:   Метод controllerWillChangeContent срабатывает перед тем, как
            изменится состояние объектов, которые добавляются или удаляются.
            В нём мы инициализируем переменные, которые содержат индексы
            изменённых объектов. */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }
    
    /* 2:   Метод controllerDidChangeContent срабатывает после
            добавления или удаления объектов. В нём мы передаём индексы
            изменённых объектов в класс MainViewController и очищаем до следующего изменения
            переменные, которые содержат индексы. */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes)
        )
        
        insertedIndexes = []
        deletedIndexes = []
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            if let sectionInfo = fetchedResultsController.sections?[sectionIndex],
               let trackers = (sectionInfo.objects?.first as? TrackerCategoryCoreData)?.trackers?.allObjects as? [TrackerCoreData],
               !trackers.isEmpty {
                for item in 0..<trackers.count {
                    insertedIndexes.append(IndexPath(item: item, section: sectionIndex))
                }
            }
        case .delete:
            deletedIndexes.append(contentsOf: (0..<numberOfRowsInSection(sectionIndex)).map {
                IndexPath(item: $0, section: sectionIndex)
            })
        default:
            break
        }
    }
}
