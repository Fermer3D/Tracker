import Foundation

final class CategoryViewModel {
    
    // MARK: - Bindings
    /// Замыкание для уведомления View об изменении структуры данных (добавление/удаление)
    var onChange: (() -> Void)?
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [String] = [] {
        didSet {
            onChange?()
        }
    }
    
    private(set) var selectedCategoryName: String?
    
    // MARK: - Initializer
    init(categoryStore: TrackerCategoryStore, selectedCategoryName: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryName = selectedCategoryName
        self.categoryStore.delegate = self
        getValuesFromStore()
    }
    
    // MARK: - Methods for TableView Data Source
    var numberOfCategories: Int {
        return categories.count
    }
    
    func categoryName(at index: Int) -> String {
        guard index >= 0 && index < categories.count else { return "" }
        return categories[index]
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        return categories[index] == selectedCategoryName
    }
    
    // MARK: - User Actions
    func selectCategory(at index: Int) {
        selectedCategoryName = categories[index]
    }
    
    func addNewCategory(title: String) {
        do {
            try categoryStore.createCategory(title: title)
            // getValuesFromStore() вызовется автоматически через делегат storeDidUpdate
        } catch {
            print("❌ [CategoryViewModel]: Ошибка добавления категории: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func getValuesFromStore() {
        categories = categoryStore.fetchCategoryTitles()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        getValuesFromStore()
    }
}
