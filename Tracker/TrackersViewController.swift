import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var currentFilter: FilterOption = .all
    
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
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        cv.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters_title", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let placeholderImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "EmptyState"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("what_to_track", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notFoundPlaceholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let notFoundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "NotFoundPlaceholder"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBg
        setupNavigationBar()
        setupUI()
        setupConstraints()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        updateFilters()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open, screen: .main)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.report(event: .close, screen: .main)
    }
    
    // MARK: - Private Methods
    private func updateFilters() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let searchText = navigationItem.searchController?.searchBar.text ?? ""
        trackerStore.updateFilters(filter: currentFilter, date: currentDate, weekday: weekday, searchText: searchText)
        reloadPlaceholders(searchText: searchText)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("trackers_title", comment: "")
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        addButton.tintColor = .appButtonBg
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(filterButton)
        view.addSubview(notFoundPlaceholderView)
        notFoundPlaceholderView.addSubview(notFoundImageView)
        notFoundPlaceholderView.addSubview(notFoundLabel)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            notFoundPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFoundImageView.centerXAnchor.constraint(equalTo: notFoundPlaceholderView.centerXAnchor),
            notFoundImageView.topAnchor.constraint(equalTo: notFoundPlaceholderView.topAnchor),
            notFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            notFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImageView.bottomAnchor, constant: 8),
            notFoundLabel.centerXAnchor.constraint(equalTo: notFoundPlaceholderView.centerXAnchor),
            notFoundLabel.bottomAnchor.constraint(equalTo: notFoundPlaceholderView.bottomAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func reloadPlaceholders(searchText: String) {
        var totalVisibleTrackers = 0
        for section in 0..<trackerStore.numberOfSections {
            totalVisibleTrackers += trackerStore.numberOfItemsInSection(section)
        }
        
        let isSearchActive = !searchText.isEmpty
        let isFilterActive = currentFilter != .all
        
        if totalVisibleTrackers == 0 {
            if isSearchActive || isFilterActive {
                collectionView.isHidden = true
                placeholderImage.isHidden = true
                placeholderLabel.isHidden = true
                notFoundPlaceholderView.isHidden = false
            } else {
                collectionView.isHidden = true
                placeholderImage.isHidden = false
                placeholderLabel.isHidden = false
                notFoundPlaceholderView.isHidden = true
            }
        } else {
            collectionView.isHidden = false
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
            notFoundPlaceholderView.isHidden = true
        }
    }
    
    private func formatDaysString(for count: Int) -> String {
        let formatString = NSLocalizedString("days_count", comment: "")
        return String.localizedStringWithFormat(formatString, count)
    }
    
    @objc private func didTapFilterButton() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)
        let filterVC = FiltersViewController(selectedFilter: currentFilter)
        filterVC.delegate = self
        present(UINavigationController(rootViewController: filterVC), animated: true)
    }
    
    @objc private func didTapAddButton() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)
        let choiceVC = ChoiceViewController()
        choiceVC.delegate = self
        present(UINavigationController(rootViewController: choiceVC), animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateFilters()
    }
}

// MARK: - Extensions
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { trackerStore.numberOfSections }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { trackerStore.numberOfItemsInSection(section) }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        guard let trackerCD = trackerStore.trackerCoreData(at: indexPath) else { return cell }
        
        let id = trackerCD.id ?? UUID()
        let color = UIColorMarshalling.color(from: trackerCD.colorHex ?? "#3772E7")
        let tracker = Tracker(id: id, name: trackerCD.name ?? "", color: color, emoji: trackerCD.emoji ?? "", schedule: nil, isPinned: trackerCD.isPinned)
        
        let records = (try? trackerRecordStore.fetchRecords()) ?? []
        let completedCount = records.filter { $0.trackerId == id }.count
        let isCompletedToday = records.contains { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompletedToday, completedDaysString: formatDaysString(for: completedCount), indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        header.titleLabel.text = trackerStore.headerLabelFor(section: indexPath.section)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32 - 9
        return CGSize(width: availableWidth / 2, height: 148)
    }
}

extension TrackersViewController: TrackerCellDelegate, TrackerStoreDelegate, FiltersViewControllerDelegate, NewHabitViewControllerDelegate, ChoiceViewControllerDelegate, UISearchResultsUpdating {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .track)
        try? trackerRecordStore.add(TrackerRecord(trackerId: id, date: Calendar.current.startOfDay(for: currentDate)))
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        try? trackerRecordStore.remove(TrackerRecord(trackerId: id, date: Calendar.current.startOfDay(for: currentDate)))
        collectionView.reloadItems(at: [indexPath])
    }
    
    func pinTracker(at indexPath: IndexPath) {
        if let tracker = trackerStore.trackerCoreData(at: indexPath) {
            try? trackerStore.togglePin(tracker: tracker)
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let tracker = trackerStore.trackerCoreData(at: indexPath) else { return }
        let alert = UIAlertController(title: NSLocalizedString("delete_alert_title", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete_button", comment: ""), style: .destructive) { [weak self] _ in
            AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
            try? self?.trackerStore.deleteTracker(tracker)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    func editTracker(at indexPath: IndexPath) {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
        guard let trackerCD = trackerStore.trackerCoreData(at: indexPath) else { return }
        let creationVC = NewHabitViewController()
        creationVC.delegate = self
        creationVC.trackerToEdit = trackerCD
        creationVC.isEditMode = true
        present(UINavigationController(rootViewController: creationVC), animated: true)
    }
    
    func storeDidChangeContent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            let searchText = self.navigationItem.searchController?.searchBar.text ?? ""
            self.reloadPlaceholders(searchText: searchText)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) { updateFilters() }
    func didSelectFilter(_ filter: FilterOption) { self.currentFilter = filter; updateFilters() }
    func didCreateTracker(_ tracker: Tracker) {}
    
    func didSelectTrackerType(isHabit: Bool) {
        let creationVC = NewHabitViewController()
        creationVC.delegate = self
        creationVC.isIrregularEvent = !isHabit
        present(UINavigationController(rootViewController: creationVC), animated: true)
    }
}
