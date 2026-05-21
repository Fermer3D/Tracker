import Foundation
import CoreData
import UIKit

// Протокол для уведомления контроллера об изменениях в базе
protocol TrackerStoreDelegate: AnyObject {
    func storeDidChangeContent()
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    // NSFetchedResultsController инкапсулирует логику работы с данными
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        // ВАЖНО: Сортировка по дескриптору секции (category.title) ОБЯЗАТЕЛЬНО должна быть первой!
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        print("ℹ️ [TrackerStore]: Инициализация FRC. Контекст: \(self.context)")
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: "category.title", // Группируем секции по названию категории автоматически
            cacheName: nil
        )
        controller.delegate = self
        
        do {
            try controller.performFetch()
            print("✅ [TrackerStore]: Первичный performFetch успешно выполнен!")
        } catch {
            print("❌ [TrackerStore]: Ошибка performFetch в lazy инициализаторе: \(error)")
        }
        
        return controller
    }()
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods (Абстракция для контроллера)
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let sections = fetchedResultsController.sections, sections.count > section else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func headerLabelFor(section: Int) -> String? {
        guard let sections = fetchedResultsController.sections, sections.count > section else {
            return nil
        }
        return sections[section].name
    }
    
    /// Безопасное получение объекта Core Data по индексу
    func trackerCoreData(at indexPath: IndexPath) -> TrackerCoreData {
        if let sections = fetchedResultsController.sections,
           sections.count > indexPath.section,
           sections[indexPath.section].numberOfObjects > indexPath.item {
            return fetchedResultsController.object(at: indexPath)
        }
        return TrackerCoreData(context: context)
    }
    
    /// Метод для обновления фильтров (день недели и поиск)
    func updateFilters(weekday: Int, searchText: String) {
        var predicates: [NSPredicate] = []
        
        if searchText.isEmpty {
            predicates.append(NSPredicate(format: "schedule CONTAINS[c] %@", String(weekday)))
        } else {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchText))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    /// Сохранение нового трекера
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        
        let scheduleString = tracker.schedule?.map { String($0.rawValue) }.joined(separator: ",") ?? ""
        trackerCoreData.setValue(scheduleString, forKey: "schedule")
        
        trackerCoreData.category = category
        
        if context.hasChanges {
            try context.save()
            print("✅ [TrackerStore]: Новый трекер '\(tracker.name)' успешно сохранен.")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChangeContent()
    }
}
