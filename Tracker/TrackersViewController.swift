import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var trackerStore: TrackerStore = {
        let context = DataProvider.shared.context
        let store = TrackerStore(context: context)
        store.delegate = self
        return store
    }()
    
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        let context = DataProvider.shared.context
        return TrackerCategoryStore(context: context)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let context = DataProvider.shared.context
        return TrackerRecordStore(context: context)
    }()
    
    private var currentDate: Date = Date()
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        cv.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let placeholderImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "EmptyState"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
        updateFilters()
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        let choiceVC = ChoiceViewController()
        choiceVC.delegate = self
        let nav = UINavigationController(rootViewController: choiceVC)
        present(nav, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateFilters()
    }
    
    // MARK: - Private Methods
    private func updateFilters() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let searchText = navigationItem.searchController?.searchBar.text ?? ""
        
        trackerStore.updateFilters(weekday: weekday, searchText: searchText)
        
        collectionView.reloadData()
        reloadPlaceholder()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func reloadPlaceholder() {
        let isSearchActive = !(navigationItem.searchController?.searchBar.text?.isEmpty ?? true)
        
        var totalItems = 0
        for section in 0..<trackerStore.numberOfSections {
            totalItems += trackerStore.numberOfItemsInSection(section)
        }
        let isDataEmpty = totalItems == 0
        
        collectionView.isHidden = isDataEmpty
        placeholderImage.isHidden = !isDataEmpty
        placeholderLabel.isHidden = !isDataEmpty
        
        if isSearchActive {
            placeholderImage.image = UIImage(named: "SearchError")
            placeholderLabel.text = "Ничего не найдено"
        } else {
            placeholderImage.image = UIImage(named: "EmptyState")
            placeholderLabel.text = "Что будем отслеживать?"
        }
    }
    
    private func formatDaysString(for count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "\(count) день" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "\(count) дня" }
        return "\(count) дней"
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateFilters()
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func storeDidChangeContent() {
        collectionView.reloadData()
        reloadPlaceholder()
    }
}

// MARK: - NewHabitViewControllerDelegate
extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        let category: TrackerCategoryCoreData?
        if let firstCategory = trackerCategoryStore.categories.first {
            category = firstCategory
        } else {
            try? trackerCategoryStore.createCategory(title: "Важное")
            category = trackerCategoryStore.categories.first
        }
        
        guard let targetCategory = category else { return }
        
        do {
            try trackerStore.addNewTracker(tracker, to: targetCategory)
            updateFilters()
        } catch {
            print("Error saving tracker: \(error)")
        }
    }
}

// MARK: - ChoiceViewControllerDelegate
extension TrackersViewController: ChoiceViewControllerDelegate {
    func didSelectTrackerType(isHabit: Bool) {
        let creationVC = NewHabitViewController()
        creationVC.delegate = self
        creationVC.isIrregularEvent = !isHabit
        let nav = UINavigationController(rootViewController: creationVC)
        self.present(nav, animated: true)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trackerCD = trackerStore.trackerCoreData(at: indexPath)
        
        let id = trackerCD.id ?? UUID()
        let name = trackerCD.name ?? ""
        let emoji = trackerCD.emoji ?? ""
        let colorHex = trackerCD.colorHex ?? "#3772E7"
        let trackerColor = UIColorMarshalling.color(from: colorHex)
        
        let allRecords = (try? trackerRecordStore.fetchRecords()) ?? []
        let isCompletedToday = allRecords.contains { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        let completedCount = allRecords.filter { $0.trackerId == id }.count
        
        let tracker = Tracker(id: id, name: name, color: trackerColor, emoji: emoji, schedule: nil)
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompletedToday, completedDaysString: formatDaysString(for: completedCount), indexPath: indexPath)
        return cell
    }
    
    // Безопасное извлечение названия секции напрямую из Store через метод headerLabelFor
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = trackerStore.headerLabelFor(section: indexPath.section) ?? "Категория"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 41) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        if Calendar.current.startOfDay(for: currentDate) > Calendar.current.startOfDay(for: Date()) { return }
        
        let allRecords = (try? trackerRecordStore.fetchRecords()) ?? []
        if !allRecords.contains(where: { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
            try? trackerRecordStore.add(TrackerRecord(trackerId: id, date: Calendar.current.startOfDay(for: currentDate)))
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        try? trackerRecordStore.remove(TrackerRecord(trackerId: id, date: Calendar.current.startOfDay(for: currentDate)))
        collectionView.reloadItems(at: [indexPath])
    }
}
