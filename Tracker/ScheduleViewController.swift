import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedDays: [WeekDay] = []
    
    // Порядок дней строго с Пн
    private let orderedDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .white
        table.layer.cornerRadius = 16
        table.isScrollEnabled = false
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Расписание"
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
    
    @objc private func didTapDoneButton() {
        let sortedResult = selectedDays.sorted { (day1, day2) -> Bool in
            guard let index1 = orderedDays.firstIndex(of: day1),
                  let index2 = orderedDays.firstIndex(of: day2) else { return false }
            return index1 < index2
        }
        delegate?.didUpdateSchedule(sortedResult)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = orderedDays[sender.tag]
        if sender.isOn {
            if !selectedDays.contains(day) { selectedDays.append(day) }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "dayCell")
        let day = orderedDays[indexPath.row]
        
        cell.textLabel?.text = day.russianName
        cell.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.selectionStyle = .none
        
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .systemBlue
        switchView.tag = indexPath.row
        switchView.isOn = selectedDays.contains(day)
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        cell.layer.cornerRadius = 16
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == orderedDays.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}
