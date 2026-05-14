import UIKit

// MARK: - Protocols
protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ selectedDays: [WeekDay])
}

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: NewHabitViewControllerDelegate?
    var isIrregularEvent: Bool = false
    private var selectedSchedule: [WeekDay] = []
    
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
        table.separatorStyle = .singleLine
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
        button.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = isIrregularEvent ? "Новое нерегулярное событие" : "Новая привычка"
        navigationItem.hidesBackButton = true
        
        setupUI()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем высоту коллекции в зависимости от контента
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func hideKeyboard() { view.endEditing(true) }
    
    @objc private func didTapCancel() { dismiss(animated: true) }
    
    @objc private func didTapCreate() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emojiIndex = selectedEmojiIndex,
              let colorIndex = selectedColorIndex else { return }
        
        let schedule = isIrregularEvent ? nil : selectedSchedule
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: colors[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: schedule
        )
        
        delegate?.didCreateTracker(newTracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        let text = nameTextField.text ?? ""
        lengthWarningLabel.isHidden = text.count <= 38
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let text = nameTextField.text ?? ""
        let hasText = !text.trimmingCharacters(in: .whitespaces).isEmpty
        let isNotTooLong = text.count <= 38
        let isScheduleValid = isIrregularEvent ? true : !selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmojiIndex != nil
        let isColorSelected = selectedColorIndex != nil
        
        let isEnabled = hasText && isNotTooLong && isScheduleValid && isEmojiSelected && isColorSelected
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .gray
    }
    
    private func setupConstraints() {
        guard let bottomStack = contentView.subviews.last as? UIStackView else { return }
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        
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
            
            lengthWarningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            lengthWarningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: isIrregularEvent ? 75 : 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewHeightConstraint!,
            
            bottomStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomStack.heightAnchor.constraint(equalToConstant: 60),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - UITableView Extensions
extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isIrregularEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        
        cell.layer.cornerRadius = 16
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.layer.maskedCorners = isIrregularEvent ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.textLabel?.text = "Расписание"
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            if !selectedSchedule.isEmpty {
                cell.detailTextLabel?.text = selectedSchedule.count == 7 ? "Каждый день" : selectedSchedule.map { $0.shortName }.joined(separator: ", ")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.selectedDays = self.selectedSchedule
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}

// MARK: - UICollectionView Extensions
extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as! EmojiCollectionViewCell
            cell.emojiLabel.text = emojis[indexPath.row]
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.backgroundColor = (indexPath.row == selectedEmojiIndex) ? UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1.0) : .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as! ColorCollectionViewCell
            let color = colors[indexPath.row]
            cell.setViewColor(color)
            cell.setSelected(indexPath.row == selectedColorIndex, with: color)
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
        let width = (collectionView.frame.width - 18 * 2 - 5 * 9) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 5 }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryView.identifier, for: indexPath) as! SupplementaryView
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}

// MARK: - Delegate Extension
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didUpdateSchedule(_ selectedDays: [WeekDay]) {
        self.selectedSchedule = selectedDays
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        updateCreateButtonState()
    }
}

// MARK: - Supplementary View Class
final class SupplementaryView: UICollectionReusableView {
    static let identifier = "header"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
