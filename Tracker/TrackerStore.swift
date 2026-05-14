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
        
        // Первичная загрузка данных
        try? fetchedResultsController.performFetch()
    }
    
    // MARK: - Public Methods (Абстракция для контроллера)
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func headerLabelFor(section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func trackerCoreData(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
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
        // Уведомляем контроллер, что данные изменились, не передавая объекты Core Data
        delegate?.storeDidChangeContent()
    }
}
