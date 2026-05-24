import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    
    // MARK: - Static Properties
    static let shared = TrackerRecordStore() // Добавляем синглтон для доступа
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    // Удобный инициализатор для работы через .shared
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Добавление новой записи о выполнении
    func add(_ record: TrackerRecord) throws {
        // Проверяем, нет ли уже такой записи, чтобы избежать дубликатов в базе
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
        
        // Фильтруем по ID и конкретной дате (день в день)
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
        // Используем такой же предикат, как для удаления/проверки
        let dateStart = Calendar.current.startOfDay(for: date)
        let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart)!
        
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
    
    /// Создание предиката для сравнения даты без учета времени (start of day)
    private func createDatePredicate(for record: TrackerRecord) -> NSPredicate {
        let dateStart = Calendar.current.startOfDay(for: record.date)
        guard let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) else {
            // Фолбэк на точное совпадение, если календарь дал сбой
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
