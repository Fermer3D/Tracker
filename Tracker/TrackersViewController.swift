import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
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
        reloadPlaceholder()
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
        collectionView.reloadData()
        reloadPlaceholder()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupUI() {
        [collectionView, placeholderImage, placeholderLabel].forEach { view.addSubview($0) }
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
        let isDataEmpty = categories.isEmpty
        collectionView.isHidden = isDataEmpty
        placeholderImage.isHidden = !isDataEmpty
        placeholderLabel.isHidden = !isDataEmpty
    }
    
    // Функция для правильного склонения дней
    private func formatDaysString(for count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        
        if mod10 == 1 && mod100 != 11 {
            return "\(count) день"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
}

// MARK: - NewHabitViewControllerDelegate
extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        if categories.isEmpty {
            categories.append(TrackerCategory(title: "Важное", trackers: [tracker]))
        } else {
            let oldCategory = categories[0]
            var trackers = oldCategory.trackers
            trackers.append(tracker)
            categories[0] = TrackerCategory(title: oldCategory.title, trackers: trackers)
        }
        
        reloadPlaceholder()
        collectionView.reloadData()
    }
}

// MARK: - CollectionView Delegate & DataSource
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { categories.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        // Проверяем, выполнен ли трекер именно в выбранную на пикере дату
        let isCompletedToday = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        // Считаем общее количество выполнений для счетчика
        let completedCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.delegate = self
        
        // Передаем отформатированную строку со склонением
        let daysString = formatDaysString(for: completedCount)
        
        cell.configure(
            with: tracker,
            isCompleted: isCompletedToday,
            completedDaysString: daysString, // Твоя ячейка должна принимать String для лейбла
            indexPath: indexPath
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32 - 9
        return CGSize(width: availableWidth / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let today = Date()
        // Нельзя отмечать в будущем
        if Calendar.current.startOfDay(for: currentDate) > Calendar.current.startOfDay(for: today) { return }
        
        let record = TrackerRecord(trackerId: id, date: Calendar.current.startOfDay(for: currentDate))
        completedTrackers.insert(record)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let date = Calendar.current.startOfDay(for: currentDate)
        completedTrackers.remove(TrackerRecord(trackerId: id, date: date))
        collectionView.reloadItems(at: [indexPath])
    }
}
