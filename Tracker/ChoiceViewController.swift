import UIKit

protocol ChoiceViewControllerDelegate: AnyObject {
    func didSelectTrackerType(isHabit: Bool)
}

final class ChoiceViewController: UIViewController {
    
    weak var delegate: ChoiceViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .custom) // Используем .custom вместо .system
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Используем цвета из Assets
        button.backgroundColor = UIColor(named: "YP Reverse")
        button.setTitleColor(UIColor(named: "YP Background"), for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true // Обязательно для скругления
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .custom) // Используем .custom вместо .system
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Используем цвета из Assets
        button.backgroundColor = UIColor(named: "YP Reverse")
        button.setTitleColor(UIColor(named: "YP Background"), for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true // Обязательно для скругления
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBg
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupViews() {
        title = "Создание трекера"
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
        
        habitButton.addTarget(self, action: #selector(didTapHabit), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(didTapIrregularEvent), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapHabit() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectTrackerType(isHabit: true)
        }
    }
    
    @objc private func didTapIrregularEvent() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectTrackerType(isHabit: false)
        }
    }
}
