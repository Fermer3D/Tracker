import Foundation
import CoreData

final class CategoryViewModel {
    
    // MARK: - Bindings
    var onChange: (() -> Void)?
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onChange?()
        }
    }
    
    // При изменении выбранной категории тоже уведомляем UI
    private(set) var selectedCategory: TrackerCategoryCoreData? {
        didSet {
            onChange?()
        }
    }
    
    // MARK: - Initializer
    init(categoryStore: TrackerCategoryStore, selectedCategory: TrackerCategoryCoreData?) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        self.categoryStore.delegate = self
        getValuesFromStore()
    }
    
    // MARK: - Methods for TableView
    var numberOfCategories: Int {
        return categories.count
    }
    
    func categoryName(at index: Int) -> String {
        return categories[index].title ?? ""
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard let selected = selectedCategory else { return false }
        // Сравнение по objectID — самый надежный способ в CoreData
        return categories[index].objectID == selected.objectID
    }
    
    func category(at index: Int) -> TrackerCategoryCoreData? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index]
    }
    
    // MARK: - User Actions
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        selectedCategory = categories[index]
    }
    
    func addNewCategory(title: String) {
        do {
            try categoryStore.createCategory(title: title)
            // После успешного создания стор через делегат вызовет getValuesFromStore()
        } catch {
            print("❌ [CategoryViewModel]: Ошибка добавления категории: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func getValuesFromStore() {
        let newCategories = categoryStore.categories
        
        // Обновляем список, срабатывает didSet и вызывает onChange?()
        self.categories = newCategories
        
        // Синхронизируем selectedCategory, если объект был пересоздан в сторе
        if let selected = selectedCategory {
            let updatedSelected = newCategories.first { $0.objectID == selected.objectID }
            if self.selectedCategory != updatedSelected {
                self.selectedCategory = updatedSelected
            }
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        // При любом обновлении данных из БД обновляем локальный список
        DispatchQueue.main.async {
            self.getValuesFromStore()
        }
    }
}
