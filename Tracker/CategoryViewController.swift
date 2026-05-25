import UIKit

// MARK: - Protocols
protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategoryCoreData)
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
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyState"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // ИСПРАВЛЕНИЕ: Делаем картинку адаптивной, если она шаблонная
        imageView.tintColor = .label
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        // ИСПРАВЛЕНИЕ: Используем адаптивный цвет .label
        label.textColor = .label
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
        // ИСПРАВЛЕНИЕ: Используем .label для текста на кнопке, если цвет кнопки темный
        button.backgroundColor = .appButtonText // Или .label
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Init
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
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.togglePlaceholder()
            }
        }
    }
    
    private func setupViews() {
        title = "Категория"
        view.backgroundColor = .ypBg
        
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
        let isEmpty = viewModel.numberOfCategories == 0
        tableView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
    
    @objc private func addCategoryTapped() {
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
        
        // ИСПРАВЛЕНИЕ: Используем адаптивный цвет ячейки
        cell.backgroundColor = .ypBackground // Убедитесь, что этот цвет задан в Assets
        cell.textLabel?.textColor = .label
        cell.selectionStyle = .none
        
        let categoryName = viewModel.categoryName(at: indexPath.row)
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        
        cell.textLabel?.text = categoryName
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        
        if let selectedCategoryObject = viewModel.category(at: indexPath.row) {
            delegate?.didSelectCategory(selectedCategoryObject)
        }
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}
