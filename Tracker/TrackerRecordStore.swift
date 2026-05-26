import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    
    // MARK: - Static Properties
    static let shared = TrackerRecordStore()
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    convenience override init() {
        // Безопасное получение AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.init(context: appDelegate.persistentContainer.viewContext)
        } else {
            // Если AppDelegate не получен, создаем контекст в памяти для предотвращения краша
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Добавление новой записи о выполнении
    func add(_ record: TrackerRecord) throws {
        if try isRecordExists(record) {
            print("⚠️ [TrackerRecordStore]: Запись уже существует, пропуск.")
            return
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.trackerId
        recordCoreData.date = record.date
        
        try context.save()
        print("✅ [TrackerRecordStore]: Запись сохранена для \(record.trackerId)")
    }
    
    /// Удаление записи
    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = createDatePredicate(for: record)
        
        let results = try context.fetch(request)
        if let recordToDelete = results.first {
            context.delete(recordToDelete)
            try context.save()
            print("🗑️ [TrackerRecordStore]: Запись удалена.")
        }
    }
    
    /// Получение всех записей для StatisticsService и UI
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let recordsCoreData = try context.fetch(request)
        
        return recordsCoreData.compactMap { coreDataRecord in
            guard let id = coreDataRecord.id,
                  let date = coreDataRecord.date else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
    }
    
    func fetchCompletedTrackerIds(for date: Date) -> [UUID] {
        let request = TrackerRecordCoreData.fetchRequest()
        let dateStart = Calendar.current.startOfDay(for: date)
        
        // Безопасное вычисление следующего дня
        guard let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) else {
            return []
        }
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", dateStart as NSDate, dateEnd as NSDate)
        
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap { $0.id }
    }
    
    // MARK: - Private Methods
    
    /// Проверка существования записи
    private func isRecordExists(_ record: TrackerRecord) throws -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = createDatePredicate(for: record)
        let count = try context.count(for: request)
        return count > 0
    }
    
    /// Создание предиката для сравнения даты без учета времени
    private func createDatePredicate(for record: TrackerRecord) -> NSPredicate {
        let dateStart = Calendar.current.startOfDay(for: record.date)
        
        // Если не удалось получить конец дня, используем строгое сравнение
        guard let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) else {
            return NSPredicate(format: "id == %@ AND date == %@", record.trackerId as CVarArg, record.date as NSDate)
        }
        
        return NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            record.trackerId as CVarArg,
            dateStart as NSDate,
            dateEnd as NSDate
        )
    }
}
