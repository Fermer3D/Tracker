import UIKit

final class ChoiceViewController: UIViewController {
    weak var delegate: NewHabitViewControllerDelegate?

    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let irregularButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Создание трекера"
        setupUI()
    }

    private func setupUI() {
        view.addSubview(habitButton)
        view.addSubview(irregularButton)

        NSLayoutConstraint.activate([
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),

            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            irregularButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        habitButton.addTarget(self, action: #selector(didTapHabit), for: .touchUpInside)
        irregularButton.addTarget(self, action: #selector(didTapIrregular), for: .touchUpInside)
    }

    @objc private func didTapHabit() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self.delegate
        newHabitVC.isIrregularEvent = false
        navigationController?.pushViewController(newHabitVC, animated: true)
    }

    @objc private func didTapIrregular() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self.delegate
        newHabitVC.isIrregularEvent = true
        navigationController?.pushViewController(newHabitVC, animated: true)
    }
}
