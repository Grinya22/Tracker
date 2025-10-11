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

extension TrackerRecordStore {
    
    // Все завершённые записи (для кэша или общих расчётов)
    func fetchAllCompletedRecords() throws -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let object = try context.fetch(fetchRequest)
        return object.compactMap { TrackerRecord(id: $0.id ?? UUID(), trackerId: $0.trackerId ?? UUID(), date: $0.date ?? Date()) }
    }
    
    // Трекеров завершено (всего или за день)
    func completedTrackersCount(for date: Date? = nil) throws -> Int {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "TrackerRecordCoreData")
        fetchRequest.resultType = .countResultType
        
        if let date = date {
            let startOfDay = Calendar.current.startOfDay(for: date) as NSDate
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay as Date)! as NSDate
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay, endOfDay)
        }
        
        return try context.count(for: fetchRequest)
    }
    
    // Идеальные дни (дни, когда все запланированные трекеры завершены)
    // Предполагаем: "идеальный" = все трекеры на этот день завершены
    func idealDaysCount() throws -> Int {
        var idealDays = 0
        
        let allRecords = try fetchAllCompletedRecords()
        let groupedByDate = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
        
        for (date, records) in groupedByDate {
            let plannedTrackers = try fetchPlannedTrackers(for: date)
            if records.count == plannedTrackers.count {
                idealDays += 1
            }
        }
        return idealDays
    }
    
    // Вспомогательный: запланированные трекеры на день (на основе schedule)
    private func fetchPlannedTrackers(for date: Date) throws -> [TrackerCoreData] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let adjustedWeekday = (weekday == 1 ? 7 : weekday - 1)  // 1 (вс) -> 7, 2 (пн) -> 1 и т.д.
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackers = try context.fetch(fetchRequest)
        
        let filteredTrackers = trackers.filter { tracker in
            guard let schedule = tracker.schedule as? [WeekDay] else {
                return false
            }
            let isPlanned = schedule.contains { $0.rawValue == adjustedWeekday }
            
            return isPlanned
        }
        
        return filteredTrackers
    }
    
    // Лучший период (самый длинный стрик — последовательные дни с завершением трекеров)
    func bestPeriod() throws -> Int {
        let allRecords = try fetchAllCompletedRecords()
        let uniqueDates = Set(allRecords.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        
        var maxStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates {
            if let previousDate = previousDate, Calendar.current.dateComponents([.day], from: previousDate, to: date).day == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            maxStreak = max(maxStreak, currentStreak)
            previousDate = date
        }
        return maxStreak
    }
    
    // Среднее значение (среднее завершённых трекеров в день)
    func averageCompletedPerDay() throws -> Int {
        let totalCompleted = try completedTrackersCount()
        let allRecords = try fetchAllCompletedRecords()
        let uniqueDays = Set(allRecords.map { Calendar.current.startOfDay(for: $0.date) }).count
        let average = uniqueDays > 0 ? Double(totalCompleted) / Double(uniqueDays) : 0
        print("Total completed: \(totalCompleted), Unique days: \(uniqueDays), Average: \(average)")
        return Int(round(average))
    }
}
