import UIKit

// ПРОТОКОЛ: Для обработки нажатия кнопки родительским PageVC
protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingButtonTapped()
}

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: OnboardingViewControllerDelegate?
    private let text: String
    private let buttonTitle: String
    private let image: UIImage? // Опциональная картинка
    
    // MARK: - Visual Elements
    // Фоновая картинка
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Большой текст над кнопкой
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Чёрная кнопка (по ТЗ и фото 2)
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        // ИСПРАВЛЕНО: Кнопка чёрная, текст белый (как на фото 2)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16 // Скругления
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(imageName: String, text: String, buttonTitle: String) {
        self.text = text
        self.buttonTitle = buttonTitle
        // Пытаемся получить картинку
        self.image = UIImage(named: imageName)
        super.init(nibName: nil, bundle: nil)
        
        // ВРЕМЕННОЕ ИСПРАВЛЕНИЕ ДЛЯ ФОНА:
        if image == nil {
            // Если картинки нет — ставим синий фон (как на фото 2), а не чёрный
            self.view.backgroundColor = UIColor(red: 0.176, green: 0.447, blue: 0.886, alpha: 1.0)
        } else {
            // Если картинка есть — ставим её
            backgroundImageView.image = image
            self.view.backgroundColor = .white // или clear
        }
        
        textLabel.text = text
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        // Добавляем картинку только если она есть
        if image != nil {
            view.addSubview(backgroundImageView)
        }
        
        view.addSubview(textLabel)
        view.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Текст: отступы 16 от краев, отступ 268 снизу (по твоему макету)
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -268),
            
            // Кнопка: снизу, высота 60, отступы 20 (как на фото 2)
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // Положение кнопки
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Констрейнты для картинки (только если она есть)
        if image != nil {
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        delegate?.onboardingButtonTapped()
    }
}
