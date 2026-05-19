import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    // Убираем значение по умолчанию, чтобы контекст передавался строго контролируемо сверху
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Добавление новой записи о выполнении с проверкой на дубликаты
    func add(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        // Обрезаем время у даты для точного сравнения только дня
        let dateStart = Calendar.current.startOfDay(for: record.date)
        
        // Безопасно вычисляем конец дня без использования !
        guard let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) else {
            return
        }
        
        // Для UUID в предикатах Core Data надежнее использовать uuidString
        request.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            record.trackerId.uuidString,
            dateStart as NSDate,
            dateEnd as NSDate
        )
        
        let count = try context.count(for: request)
        
        // Если запись уже есть, ничего не добавляем
        guard count == 0 else { return }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.trackerId
        recordCoreData.date = record.date
        
        if context.hasChanges {
            try context.save()
            print("✅ [TrackerRecordStore]: Запись о выполнении трекера \(record.trackerId) сохранена.")
        }
    }
    
    /// Удаление записи
    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        let dateStart = Calendar.current.startOfDay(for: record.date)
        
        // Безопасно вычисляем конец дня
        guard let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart) else {
            return
        }
        
        request.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            record.trackerId.uuidString,
            dateStart as NSDate,
            dateEnd as NSDate
        )
        
        let results = try context.fetch(request)
        if let recordToDelete = results.first {
            context.delete(recordToDelete)
            
            if context.hasChanges {
                try context.save()
                print("🗑️ [TrackerRecordStore]: Запись о выполнении трекера \(record.trackerId) удалена.")
            }
        }
    }
    
    /// Получение всех записей
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let recordsCoreData = try context.fetch(request)
        
        return recordsCoreData.compactMap { record in
            guard let id = record.id,
                  let date = record.date else {
                return nil
            }
            return TrackerRecord(trackerId: id, date: date)
        }
    }
}
