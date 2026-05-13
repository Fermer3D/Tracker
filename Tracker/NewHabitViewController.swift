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
    
    // MARK: - UI Elements
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
        label.textAlignment = .center
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = isIrregularEvent ? "Новое нерегулярное событие" : "Новая привычка"
        navigationItem.hidesBackButton = true
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        [nameTextField, lengthWarningLabel, tableView].forEach { view.addSubview($0) }
        
        let hStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillEqually
        hStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)
        
        tableView.dataSource = self
        tableView.delegate = self
        // Регистрируем стандартную ячейку
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func hideKeyboard() { view.endEditing(true) }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let schedule = isIrregularEvent ? nil : selectedSchedule
        
        let colors: [UIColor] = [.systemRed, .systemOrange, .systemBlue, .systemPurple, .systemGreen, .systemPink]
        let emojis = ["🌻", "❤️", "⭐", "🚀", "🍕", "⚽", "🧩", "🎸"]
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: colors.randomElement() ?? .systemGreen,
            emoji: emojis.randomElement() ?? "🌻",
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
        
        let isEnabled = hasText && isNotTooLong && isScheduleValid
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .gray
    }
    
    private func setupConstraints() {
        // Находим стек кнопок в сабвьюхах
        guard let bottomStack = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            lengthWarningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            lengthWarningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lengthWarningLabel.heightAnchor.constraint(equalToConstant: 22),

            // Таблица теперь корректно отодвинута, чтобы хватило места под ошибку
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 50),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: isIrregularEvent ? 75 : 150),
            
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func getShortName(for day: WeekDay) -> String {
        return day.shortName // Используем свойство из твоего Models.swift
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isIrregularEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Правильное переиспользование ячейки
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .gray
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            if isIrregularEvent {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        } else {
            cell.textLabel?.text = "Расписание"
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            
            if !selectedSchedule.isEmpty {
                if selectedSchedule.count == 7 {
                    cell.detailTextLabel?.text = "Каждый день"
                } else {
                    let days = selectedSchedule.map { $0.shortName }.joined(separator: ", ")
                    cell.detailTextLabel?.text = days
                }
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

// MARK: - ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didUpdateSchedule(_ selectedDays: [WeekDay]) {
        self.selectedSchedule = selectedDays
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        updateCreateButtonState()
    }
}
