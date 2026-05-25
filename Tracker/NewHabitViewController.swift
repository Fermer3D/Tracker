import UIKit
import CoreData

final class NewHabitViewController: UIViewController, CategoryViewControllerDelegate, ScheduleViewControllerDelegate {
    
    // MARK: - Properties
    weak var delegate: NewHabitViewControllerDelegate?
    var isIrregularEvent: Bool = false
    var trackerToEdit: TrackerCoreData?
    var isEditMode: Bool = false
    
    private var selectedSchedule: [WeekDay] = []
    private var selectedCategory: TrackerCategoryCoreData?
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
    private let emojis = ["😊", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple,
        .systemPink, .systemTeal, .systemIndigo, .systemGray, .brown, .cyan,
        .magenta, .orange, .blue, .red, .green, .black
    ]
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let lengthWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.isScrollEnabled = false
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.layer.cornerRadius = 16
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBg
        navigationItem.title = isEditMode ? "Редактирование привычки" : (isIrregularEvent ? "Новое нерегулярное событие" : "Новая привычка")
        
        setupUI()
        setupConstraints()
        
        if isEditMode { setupEditMode() }
    }
    
    private func setupEditMode() {
        guard let tracker = trackerToEdit else { return }
        nameTextField.text = tracker.name
        selectedCategory = tracker.category
        if let sched = tracker.schedule {
            selectedSchedule = sched.components(separatedBy: ",").compactMap { WeekDay(rawValue: Int($0) ?? 0) }
        }
        if let emoji = tracker.emoji, let index = emojis.firstIndex(of: emoji) { selectedEmojiIndex = index }
        if let hex = tracker.colorHex {
            let color = UIColorMarshalling.color(from: hex)
            if let index = colors.firstIndex(where: { $0.isEqual(color) }) { selectedColorIndex = index }
        }
        createButton.setTitle("Сохранить", for: .normal)
        updateCreateButtonState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewHeightConstraint?.constant = collectionView.contentSize.height
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [nameTextField, lengthWarningLabel, tableView, collectionView].forEach { contentView.addSubview($0) }
        
        let hStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillEqually
        hStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hStack)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SupplementaryView.identifier)
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
    }

    @objc private func didTapCreate() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emojiIndex = selectedEmojiIndex,
              let colorIndex = selectedColorIndex,
              let category = selectedCategory else { return }

        if isEditMode, let tracker = trackerToEdit {
            tracker.name = name
            tracker.emoji = emojis[emojiIndex]
            tracker.colorHex = UIColorMarshalling.hexString(from: colors[colorIndex])
            tracker.category = category
            tracker.schedule = isIrregularEvent ? nil : selectedSchedule.map { String($0.rawValue) }.joined(separator: ",")
            try? DataProvider.shared.context.save()
            dismiss(animated: true)
        } else {
            let newTracker = Tracker(id: UUID(), name: name, color: colors[colorIndex], emoji: emojis[emojiIndex], schedule: isIrregularEvent ? nil : selectedSchedule, isPinned: false)
            try? TrackerStore.shared.addNewTracker(newTracker, to: category.objectID)
            delegate?.didCreateTracker(newTracker)
            dismiss(animated: true)
        }
    }
    
    @objc private func didTapCancel() { dismiss(animated: true) }
    
    @objc private func textFieldDidChange() {
        let text = nameTextField.text ?? ""
        lengthWarningLabel.isHidden = text.count <= 38
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let text = nameTextField.text ?? ""
        let isEnabled = !text.isEmpty && text.count <= 38 && (isIrregularEvent || !selectedSchedule.isEmpty) && selectedEmojiIndex != nil && selectedColorIndex != nil && selectedCategory != nil
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .gray
    }
    
    private func setupConstraints() {
        guard let hStack = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: isIrregularEvent ? 75 : 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heightConstraint,
            
            hStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hStack.heightAnchor.constraint(equalToConstant: 60),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    func didSelectCategory(_ category: TrackerCategoryCoreData) {
        self.selectedCategory = category
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        updateCreateButtonState()
    }
    
    func didUpdateSchedule(_ selectedDays: [WeekDay]) {
        self.selectedSchedule = selectedDays
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        updateCreateButtonState()
    }
}

// MARK: - UITableView
extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { isIrregularEvent ? 1 : 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.detailTextLabel?.textColor = .gray
        if indexPath.row == 0, let category = selectedCategory { cell.detailTextLabel?.text = category.title }
        if indexPath.row == 1, !selectedSchedule.isEmpty {
            cell.detailTextLabel?.text = selectedSchedule.count == 7 ? "Каждый день" : selectedSchedule.map { $0.shortName }.joined(separator: ", ")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryVC = CategoryViewController(viewModel: CategoryViewModel(categoryStore: TrackerCategoryStore(context: DataProvider.shared.context), selectedCategory: selectedCategory))
            categoryVC.delegate = self
            present(UINavigationController(rootViewController: categoryVC), animated: true)
        } else {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.selectedDays = self.selectedSchedule
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}

// MARK: - UICollectionView
extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { section == 0 ? emojis.count : colors.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            cell.emojiLabel.text = emojis[indexPath.row]
            cell.contentView.backgroundColor = (indexPath.row == selectedEmojiIndex) ? UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1.0) : .clear
            cell.contentView.layer.cornerRadius = 16
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            cell.setViewColor(colors[indexPath.row])
            cell.setSelected(indexPath.row == selectedColorIndex, with: colors[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmojiIndex = indexPath.row
        } else {
            selectedColorIndex = indexPath.row
        }
        collectionView.reloadData()
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 36 - 25) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 5 }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryView.identifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { CGSize(width: collectionView.frame.width, height: 34) }
}
