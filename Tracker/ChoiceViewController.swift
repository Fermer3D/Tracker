import UIKit

protocol ChoiceViewControllerDelegate: AnyObject {
    func didSelectTrackerType(isHabit: Bool)
}

final class ChoiceViewController: UIViewController {
    
    weak var delegate: ChoiceViewControllerDelegate?
    
    // MARK: - UI Elements
    // Лишний titleLabel убран, чтобы заголовок не двоился
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
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
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .white
        title = "Создание трекера" // Оставляем только системный заголовок в UINavigationBar
        
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
        print("ℹ️ [ChoiceVC]: Нажата кнопка 'Привычка'. Закрываем экран выбора...")
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectTrackerType(isHabit: true)
        }
    }
    
    @objc private func didTapIrregularEvent() {
        print("ℹ️ [ChoiceVC]: Нажата кнопка 'Нерегулярное событие'. Закрываем экран выбора...")
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectTrackerType(isHabit: false)
        }
    }
}
