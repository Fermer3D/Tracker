//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Данил Третьяченко on 24.05.2026.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterOption)
}

final class FiltersViewController: UIViewController {
    
    private let selectedFilter: FilterOption
    weak var delegate: FiltersViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.layer.cornerRadius = 16 // Добавил скругление, чтобы выглядело аккуратнее
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Получаем все варианты фильтров из enum
    private let filters: [FilterOption] = FilterOption.allCases
    
    init(selectedFilter: FilterOption) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBg
        title = "Фильтры"
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.title
        cell.backgroundColor = .systemGray6
        
        // ПРАВКА ПО РЕВЬЮ: Галочка не ставится для "Все" и "Сегодня"
        if filter == .all || filter == .today {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = filters[indexPath.row]
        delegate?.didSelectFilter(selected)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
