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
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Inits
    // Основной инициализатор, принимающий контекст (лучший вариант для DI)
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // Удобный инициализатор, который берет контекст из AppDelegate
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate для инициализации TrackerCategoryStore")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        // Сортировка по алфавиту
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("❌ [TrackerCategoryStore]: Ошибка при первом выполнении fetch: \(error)")
        }
    }
    
    // MARK: - Public Methods
    var categories: [TrackerCategoryCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func createCategory(title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        // Регистронезависимый поиск
        request.predicate = NSPredicate(format: "title ==[c] %@", title)
        
        let count = try context.count(for: request)
        
        guard count == 0 else {
            print("ℹ️ [TrackerCategoryStore]: Категория '\(title)' уже существует.")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        try context.save()
        print("✅ [TrackerCategoryStore]: Категория '\(title)' успешно сохранена.")
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата об изменениях в базе данных
        delegate?.storeDidUpdate(self)
    }
}
