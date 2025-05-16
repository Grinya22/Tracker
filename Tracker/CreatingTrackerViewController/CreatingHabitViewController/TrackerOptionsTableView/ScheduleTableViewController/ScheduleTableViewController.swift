import UIKit

protocol ScheduleTableViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [String])
}

final class ScheduleTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var selectedDays: [Bool] = Array(repeating: false, count: 7)
    
    var selectedDaysAbbreviations: [String] = []
    
    let dayAbbreviations: [String: String] = [
        "Понедельник": "Пн",
        "Вторник": "Вт",
        "Среда": "Ср",
        "Четверг": "Чт",
        "Пятница": "Пт",
        "Суббота": "Сб",
        "Воскресенье": "Вс"
    ]
    
    weak var delegate: ScheduleTableViewControllerDelegate?
            
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        setUpScheduleTableViewController()
        loadDays()
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.backBarButtonItem?.title = ""
        
        navigationItem.title = "Расписание"
    }
    
    func setUpScheduleTableViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 7)
        ])
        
        let doneButton = UIButton()
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.backgroundColor = .ypBlack
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier) as? ScheduleTableViewCell else { return UITableViewCell() }
        cell.dayLabel.text = days[indexPath.row]
        cell.daySwitch.isOn = selectedDays[indexPath.row]
        
        cell.selectionStyle = .none
        
        cell.switchChanged = { [ weak self ] isOn in
            self?.selectedDays[indexPath.row] = isOn
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == days.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    @objc
    func doneButtonTapped() {
        for i in 0..<days.count {
            if selectedDays[i] {
                let fullDay = days[i]
                let shortDay = dayAbbreviations[fullDay]
                selectedDaysAbbreviations.append(shortDay ?? "")
            }
        }
        
        print(selectedDaysAbbreviations)
        saveDays()
        delegate?.didSelectDays(selectedDaysAbbreviations)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Сохранение и загрузка дней
    private func saveDays() {
        UserDefaults.standard.set(selectedDays, forKey: "savedDays")
    }
    
    private func loadDays() {
        if let saveData = UserDefaults.standard.array(forKey: "savedDays") as? [Bool] {
            selectedDays = saveData
        }
    }
}
