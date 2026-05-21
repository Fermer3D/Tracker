import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ categoryName: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private let viewModel: CategoryViewModel
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyState")) // Убедись, что картинка со звездой есть в Assets
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init
    // ИСПРАВЛЕНО: Убрали categoryStore из параметров, контроллер знает только про ViewModel
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        bindViewModel()
        togglePlaceholder()
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.togglePlaceholder()
        }
    }
    
    private func setupViews() {
        title = "Категория"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addCategoryButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func togglePlaceholder() {
        // ИСПРАВЛЕНО: Безопасное обращение к количеству элементов через ViewModel
        let isEmpty = viewModel.numberOfCategories == 0
        tableView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
    
    @objc private func addCategoryTapped() {
        // Здесь презентуешь экран создания категории.
        // Если используешь NewCategoryViewController, передавай туда ВьюМодель или создавай вьюмодель создания внутри.
        // Пример вызова алерта (как временное решение для проверки):
        let alert = UIAlertController(title: "Новая категория", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Введите название категории" }
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self?.viewModel.addNewCategory(title: text)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ИСПРАВЛЕНО: Чистый вызов через методы ViewModel
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // ИСПРАВЛЕНО: Данные берутся только через интерфейс методов ВьюМодели
        let categoryName = viewModel.categoryName(at: indexPath.row)
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        let totalRows = viewModel.numberOfCategories
        
        var content = cell.defaultContentConfiguration()
        content.text = categoryName
        content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
        cell.contentConfiguration = content
        
        cell.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        cell.selectionStyle = .none
        cell.accessoryType = isSelected ? .checkmark : .none
        
        // Сброс старых разделителей и углов, чтобы ячейки при переиспользовании не ломались
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Настройка скруглений углов по ТЗ
        if totalRows == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            addSeparator(to: cell)
        } else if indexPath.row == totalRows - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            addSeparator(to: cell)
        }
        
        return cell
    }
    
    private func addSeparator(to cell: UITableViewCell) {
        let separator = UIView()
        separator.backgroundColor = .lightGray.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.tag = 999
        cell.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ИСПРАВЛЕНО: Индекс передается числом, логика выбора инкапсулирована
        viewModel.selectCategory(at: indexPath.row)
        let selectedName = viewModel.categoryName(at: indexPath.row)
        
        delegate?.didSelectCategory(selectedName)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
