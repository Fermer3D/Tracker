import Foundation
import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    // ИСПРАВЛЕНО: Сделали контроллер безопасным опционалом вместо неявного развертывания (!)
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Inits
    override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Не удалось получить AppDelegate")
            let container = NSPersistentContainer(name: "Tracker")
            container.loadPersistentStores { _, _ in }
            self.context = container.viewContext
            super.init()
            setupFetchedResultsController()
            return
        }
        
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        setupFetchedResultsController()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        do {
            try controller.performFetch()
            // ИСПРАВЛЕНО: Безопасное присвоение опциональной переменной
            self.fetchedResultsController = controller
        } catch {
            print("❌ [TrackerCategoryStore]: Ошибка performFetch: \(error)")
        }
    }
    
    // MARK: - Public Methods
    var categories: [TrackerCategoryCoreData] {
        // ИСПРАВЛЕНО: Опциональная цепочка теперь работает с реальным опционалом.
        // Если контроллер по какой-то причине nil, метод безопасно вернет пустой массив.
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchCategoryTitles() -> [String] {
        return categories.compactMap { $0.title }
    }
    
    func createCategory(title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title ==[c] %@", title)
        let count = try context.count(for: request)
        
        guard count == 0 else {
            print("ℹ️ [TrackerCategoryStore]: Категория '\(title)' уже существует.")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        if context.hasChanges {
            try context.save()
            print("✅ [TrackerCategoryStore]: Категория '\(title)' успешно сохранена.")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
