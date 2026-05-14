//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Данил Третьяченко on 13.05.2026.
//

import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = DataProvider.shared.context) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    // Добавление новой записи о выполнении с проверкой на дубликаты
    func add(_ record: TrackerRecord) throws {
        // Проверяем, нет ли уже такой записи в базе (чтобы счетчик не рос бесконечно)
        let request = TrackerRecordCoreData.fetchRequest()
        
        // Обрезаем время у даты для точного сравнения только дня
        let dateStart = Calendar.current.startOfDay(for: record.date)
        let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart)!
        
        request.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            record.trackerId as CVarArg,
            dateStart as NSDate,
            dateEnd as NSDate
        )
        
        let count = try context.count(for: request)
        
        // Если запись уже есть, ничего не добавляем
        guard count == 0 else { return }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.trackerId
        recordCoreData.date = record.date
        
        try context.save()
    }
    
    // Удаление записи
    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        // Аналогично используем диапазон дат для корректного поиска записи за день
        let dateStart = Calendar.current.startOfDay(for: record.date)
        let dateEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateStart)!
        
        request.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            record.trackerId as CVarArg,
            dateStart as NSDate,
            dateEnd as NSDate
        )
        
        let results = try context.fetch(request)
        if let recordToDelete = results.first {
            context.delete(recordToDelete)
            try context.save()
        }
    }
    
    // Получение всех записей
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
