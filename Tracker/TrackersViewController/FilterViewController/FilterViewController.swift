import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    private var itemsOfTableView: [String] = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    
    weak var delegate: FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamicBackground
        title = "Фильтры"
        tableView.tableHeaderView = UIView()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .dynamicBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.shadowColor = nil
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.logEvent(.open(screen: "FilterSelection"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.logEvent(.close(screen: "FilterSelection"))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .dynamicTextFieldOrTableViewBackgroundColor
        tableView.layer.cornerRadius = 16
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsOfTableView.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = itemsOfTableView[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .dynamicTitleColor
        cell.backgroundColor = .clear
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemsOfTableView.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsService.shared.logEvent(.click(screen: "FilterSelection", item: "filter_\(indexPath.row)"))
        let selectedFilter: FilterType
        
        switch indexPath.row {
        case 0:
            selectedFilter = .all
        case 1:
            selectedFilter = .today(Date())
        case 2:
            selectedFilter = .completed(Date())
        case 3:
            selectedFilter = .uncompleted(Date())
        default:
            selectedFilter = .all
        }
        
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
    
    func deselectSelectedRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


