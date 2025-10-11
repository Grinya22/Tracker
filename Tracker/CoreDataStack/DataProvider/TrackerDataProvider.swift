import UIKit
import CoreData

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
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
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
                        color: obj.color as? UIColor ?? .ypGray,
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
        cleanExpiredIrregularTrackers()
        
        let fetchRequest = fetchedResultsController.fetchRequest
        
        let date: Date
        
        switch filter {
        case .all:
            date = Date()
        case .today(let myDate), .completed(let myDate), .uncompleted(let myDate):
            date = myDate
        }
        
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
            delegate?.setFilter(filter)
        } catch {
            print("Ошибка при выборке: \(error)")
        }
    }
    
    func cleanExpiredIrregularTrackers() {
        do {
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            fetchRequest.predicate = NSPredicate(format: "creationDate < %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate)
            
            let allTrackers = try context.fetch(fetchRequest)
            let expiredIrregularTracker = allTrackers.filter { ($0.schedule as? [WeekDay])?.isEmpty ?? true }
            
            for tracker in expiredIrregularTracker {
                try trackerStore.deleteTracker(tracker)
            }
            
            let categoryFetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            let categories = try context.fetch(categoryFetchRequest)
            for category in categories {
                if let trackers = category.trackers, trackers.count == 0 {
                    try categoryStore.deleteCategory(category)
                }
            }
            
            CoreDataStack.shared.saveContext()
            
            try fetchedResultsController.performFetch()
            delegate?.didUpdate(TrackerStoreUpdate(insertedIndexes: [], deletedIndexes: [], insertedSections: [], deletedSections: []))
        } catch {
            print("Ошибка при очистке устаревших трекеров или категорий: \(error)")
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
            color: trackerObject.color as? UIColor ?? .ypGray,
            emoji: trackerObject.emoji ?? "",
            schedule: (trackerObject.schedule as? [WeekDay]) ?? [],
            creationDate: trackerObject.creationDate ?? Date()
        )
    }
    
    func categoryTitle(forSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        let categories = try context.fetch(fetchRequest)

        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = try categoryStore.addCategory(categoryTitle)
        }

        try trackerStore.addTracker(tracker, to: category)

        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        guard indexPath.section < fetchedResultsController.sections?.count ?? 0,
              let sectionInfo = fetchedResultsController.sections?[indexPath.section],
              let category = sectionInfo.objects?.first as? TrackerCategoryCoreData,
              let trackers = category.trackers?.allObjects as? [TrackerCoreData],
              indexPath.row < trackers.count else {
                  return
        }
        
        let tracker = trackers[indexPath.row]
        try trackerStore.deleteTracker(tracker)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        insertedSections = []
        deletedSections = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
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
        case .update:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
                insertedIndexes.append(indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                deletedIndexes.append(indexPath)
                insertedIndexes.append(newIndexPath)
            }
        @unknown default:
            break
        }
    }
}
