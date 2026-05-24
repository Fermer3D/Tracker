import Foundation
import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidChangeContent()
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    static let shared = TrackerStore()
    
    private let context: NSManagedObjectContext

    private override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    private var _fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> {
        if let frc = _fetchedResultsController {
            return frc
        }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title", // Исправлено: обычно используется свойство категории
            cacheName: nil
        )
        
        frc.delegate = self
        _fetchedResultsController = frc
        
        do {
            try frc.performFetch()
        } catch {
            print("❌ Ошибка FRC при инициализации: \(error)")
        }
        
        return frc
    }
    
    // MARK: - Public Methods (CRUD)
    
    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackerCDs = try context.fetch(fetchRequest)
        
        return trackerCDs.compactMap { cd in
            guard let id = cd.id, let name = cd.name, let colorHex = cd.colorHex, let emoji = cd.emoji else { return nil }
            return Tracker(
                id: id,
                name: name,
                color: UIColorMarshalling.color(from: colorHex),
                emoji: emoji,
                schedule: cd.schedule?.components(separatedBy: ",").compactMap { WeekDay(rawValue: Int($0) ?? 0) },
                isPinned: cd.isPinned
            )
        }
    }
    
    func togglePin(tracker: TrackerCoreData) throws {
        context.performAndWait {
            tracker.isPinned.toggle()
        }
        try context.save()
    }

    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.performAndWait {
            context.delete(tracker)
        }
        try context.save()
    }
    
    func updateFilters(filter: FilterOption, date: Date, weekday: Int, searchText: String) {
        var predicates: [NSPredicate] = []
        
        predicates.append(NSPredicate(format: "schedule CONTAINS[c] %@ OR schedule == nil OR schedule == ''", String(weekday)))
        
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchText))
        }
        
        if filter == .completed {
            let completedIds = TrackerRecordStore.shared.fetchCompletedTrackerIds(for: date)
            predicates.append(NSPredicate(format: "id IN %@", completedIds))
        } else if filter == .notCompleted {
            let completedIds = TrackerRecordStore.shared.fetchCompletedTrackerIds(for: date)
            predicates.append(NSPredicate(format: "NOT (id IN %@)", completedIds))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
            delegate?.storeDidChangeContent()
        } catch {
            print("❌ Ошибка при обновлении фильтров: \(error)")
        }
    }
    
    func addNewTracker(_ tracker: Tracker, to categoryID: NSManagedObjectID) throws {
        let categoryInContext = try context.existingObject(with: categoryID) as! TrackerCategoryCoreData
        
        // ПРОВЕРКА НА ДУБЛИКАТ:
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        let count = try context.count(for: fetchRequest)
        
        if count > 0 { return } // Если такой ID уже есть, не создаем новый
        
        context.performAndWait {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
            trackerCoreData.isPinned = tracker.isPinned
            trackerCoreData.schedule = tracker.schedule?.map { String($0.rawValue) }.joined(separator: ",")
            trackerCoreData.category = categoryInContext
        }
        
        try context.save()
        // Делегат вызовется автоматически через controllerDidChangeContent
    }
    
    // MARK: - Data Accessors
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChangeContent()
    }
}
