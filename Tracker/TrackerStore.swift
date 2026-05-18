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
    
    // NSFetchedResultsController теперь живет здесь, инкапсулируя логику Core Data
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Init
    init(context: NSManagedObjectContext = DataProvider.shared.context) {
        self.context = context
        super.init()
        
        // Первичная загрузка данных (безопасно игнорируем ошибку, так как при пустой базе это норма)
        try? fetchedResultsController.performFetch()
    }
    
    // MARK: - Public Methods (Абстракция для контроллера)
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        // Безопасно получаем количество объектов в секции
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
        // Если индекс валиден — возвращаем объект, если нет — создаем временный пустой объект в контексте
        // чтобы избежать force unwrap и падения всего приложения
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
            // Только по дню недели
            predicates.append(NSPredicate(format: "schedule CONTAINS[c] %@", String(weekday)))
        } else {
            // По поиску (игнорируя день недели для удобства пользователя)
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
        
        // Используем KVC для записи, чтобы избежать конфликтов типов с автогенерацией Xcode
        let scheduleString = tracker.schedule?.map { String($0.rawValue) }.joined(separator: ",") ?? ""
        trackerCoreData.setValue(scheduleString, forKey: "schedule")
        
        trackerCoreData.category = category
        
        if context.hasChanges {
            try context.save()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем контроллер об изменениях через делегат
        delegate?.storeDidChangeContent()
    }
}
